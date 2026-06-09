#!/usr/bin/env python3
# devops/hds-anonymizer/main.py - pseudonymisation k-anonymat (extrait significatif)
import os
import hmac
import hashlib
import logging
from typing import Iterator

from faker import Faker
from sqlalchemy import create_engine, text

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("hds-anonymizer")

fake = Faker("fr_FR")
K = int(os.getenv("K_ANON_VALUE", "5"))
SALT = os.environ["ANON_SALT"]  # injecté via secret K8s, jamais en clair


def hash_identifier(value: str, salt: str) -> str:
    """Pseudonymise un identifiant direct (HMAC-SHA256, non réversible sans le sel)."""
    return hmac.new(salt.encode(), value.encode(), hashlib.sha256).hexdigest()[:16]


def anonymize_patient(row: dict, salt: str) -> dict:
    """Supprime les identifiants directs et généralise les quasi-identifiants."""
    age = int(row.get("age", 0))
    return {
        "id_pseudo": hash_identifier(row["nir"], salt),
        "nom": fake.last_name(),
        "prenom": fake.first_name(),
        "age_tranche": f"{age // 10 * 10}-{age // 10 * 10 + 9}",
        "code_postal": str(row.get("code_postal", "00000"))[:2] + "***",
        "sexe": row.get("sexe", "N"),
        "pathologie": row.get("pathologie"),
    }


def verify_k_anonymity(conn, table: str, quasi_ids: list[str], k: int) -> bool:
    cols = ", ".join(quasi_ids)
    q = text(f"SELECT MIN(c) FROM (SELECT COUNT(*) AS c FROM {table} GROUP BY {cols}) s")
    return (conn.execute(q).scalar() or 0) >= k


def main() -> int:
    src = create_engine(os.environ["SOURCE_DB_DSN"])
    dst = create_engine(os.environ["TARGET_DB_DSN"])
    with src.connect() as s, dst.begin() as d:
        rows: Iterator[dict] = (dict(r._mapping) for r in s.execute(text("SELECT * FROM patients")))
        for row in rows:
            rec = anonymize_patient(row, SALT)
            d.execute(text(
                "INSERT INTO patients_anon (id_pseudo, nom, prenom, age_tranche, "
                "code_postal, sexe, pathologie) VALUES (:id_pseudo,:nom,:prenom,"
                ":age_tranche,:code_postal,:sexe,:pathologie)"), rec)
        if not verify_k_anonymity(d, "patients_anon", ["age_tranche", "code_postal", "sexe"], K):
            log.error("Echec k-anonymat (k<%d) : rollback", K)
            raise SystemExit(1)
    log.info("Anonymisation terminée (k>=%d).", K)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
