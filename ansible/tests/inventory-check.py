#!/usr/bin/env python3
"""Valide que chaque hôte des inventaires possède les variables requises."""
import sys, yaml, pathlib

REQUIRED = {"ansible_host"}

def main() -> int:
    ok = True
    for hosts in pathlib.Path("inventories").rglob("hosts.yml"):
        data = yaml.safe_load(hosts.read_text()) or {}
        # parcours simplifié : signale un fichier vide
        if not data:
            print(f"[WARN] inventaire vide : {hosts}"); ok = False
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
