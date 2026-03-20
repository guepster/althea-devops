#!/usr/bin/env python3
"""Anonymisation k-anonymat des jeux de données de santé (extrait).
Réduit les quasi-identifiants pour garantir k>=K avant export hors PROD.
"""
import argparse
import pandas as pd

K = 5  # seuil de k-anonymat


def generalize(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["age"] = (df["age"] // 10 * 10).astype(str) + "-" + ((df["age"] // 10 * 10) + 9).astype(str)
    df["code_postal"] = df["code_postal"].astype(str).str[:2] + "***"
    return df


def k_anonymous(df: pd.DataFrame, quasi_ids: list[str]) -> bool:
    return df.groupby(quasi_ids).size().min() >= K


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("input")
    p.add_argument("output")
    args = p.parse_args()

    df = pd.read_csv(args.input)
    df = df.drop(columns=["nom", "prenom", "nir"], errors="ignore")  # identifiants directs
    df = generalize(df)

    quasi = ["age", "code_postal", "sexe"]
    if not k_anonymous(df, quasi):
        raise SystemExit(f"Echec k-anonymat (k<{K}) : export refusé.")

    df.to_csv(args.output, index=False)
    print(f"OK — export anonymisé (k>={K}) : {args.output}")


if __name__ == "__main__":
    main()
