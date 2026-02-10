# RB-002 — Bascule Wazuh primaire vers DR On-Premise

**Objectif** : reprendre le SIEM sur WAZ-ALT-DR si le cluster Azure est indisponible.
**RTO** : < 30 min — **RPO** : < 5 min.

1. Vérifier l'indisponibilité du master WAZ-ALT-01 (ping/API).
2. Promouvoir WAZ-ALT-DR (master standby) : `systemctl start wazuh-manager`.
3. Rediriger les agents (DNS `wazuh.althea.local` → IP DR).
4. Vérifier la réception des événements dans Grafana (datasource Wazuh).
5. Notifier le SOC et ouvrir un ticket JSM de suivi.
