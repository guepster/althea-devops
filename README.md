# Althea Systems — Plateforme DevOps (Aleeph)

Code source de la chaîne DevOps & Gouvernance déployée pour **Althea Systems**
(périmètre Paris · Genève · Azure France Centre). Ce dépôt accompagne le
Document d'Architecture Technique (DAT) et regroupe l'infrastructure-as-code,
les pipelines CI/CD, la stack de supervision et les procédures d'exploitation.

> Contexte : refonte d'un SI hébergeant des données de santé (conformité
> **HDS · RGPD · ANSSI · ISO 27001**). Auteur : Shems AIT ALI SLIMANE — DevOps.

---

## 1. Architecture (résumé)

| Domaine            | Outils                                                        |
|--------------------|---------------------------------------------------------------|
| IaC                | Terraform (Azure) + Ansible (configuration)                   |
| CI/CD              | GitLab CI/CD (lint, scan, build, deploy)                      |
| DevSecOps          | SonarQube, Trivy, Checkov, tfsec, GitLeaks                    |
| Supervision        | Zabbix + Grafana (Docker) derrière HAProxy + SSO Entra ID     |
| SIEM / SOAR        | Wazuh (cluster) + Shuffle                                     |
| Secrets            | Azure Key Vault (Standard + HSM), rotation Ansible AWX        |
| Résilience         | Veeam + Azure Site Recovery, DR On-Premise + Suisse Nord      |

## 2. Prérequis (installation de l'outillage)

```bash
terraform >= 1.7.5
ansible    >= 2.16
az cli      (Azure CLI, authentifié : az login)
docker / docker compose   (pour la stack supervision)
```

## 3. Configuration

1. Copier les fichiers d'exemple et renseigner vos valeurs :
   ```bash
   cp terraform/envs/prod/terraform.tfvars.example terraform/envs/prod/terraform.tfvars
   ```
2. Les secrets ne sont **jamais** committés : ils sont injectés via les
   *CI/CD Variables* GitLab (protégées + masquées) et Azure Key Vault.
   Le vault Ansible (`ansible/vault/`) est chiffré (`ansible-vault`).

## 4. Déploiement (fonctionnement)

```bash
# 1) Provisionner l'infrastructure Azure
cd terraform/envs/prod
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# 2) Configurer les hôtes (durcissement, Docker, stack supervision...)
cd ../../../ansible
ansible-playbook -i inventories/prod/hosts.yml site.yml

# 3) Démarrer la stack de supervision (si déploiement manuel)
cd ../monitoring
docker compose up -d
```

En production, **aucune installation manuelle** n'est tolérée : tout passe par
le pipeline `.gitlab-ci.yml` (voir section CI/CD du DAT).

## 5. Structure du dépôt

```
.
├── .gitlab-ci.yml          # Pipeline CI/CD de référence
├── terraform/              # Infrastructure Azure (modules + environnements)
├── ansible/                # Configuration des hôtes (rôles + playbooks)
├── monitoring/             # Stack supervision (docker-compose + HAProxy)
├── siem/                   # Configuration Wazuh (ossec.conf)
├── scripts/                # Outils (anonymisation HDS...)
├── runbooks/               # Procédures d'exploitation (PRA/PCA)
└── docs/                   # Documentation / lien vers le DAT
```

## 6. Conventions

- **Versionnement** : Semantic Versioning 2.0.0, tags Git (`vX.Y.Z`).
- **Branches** : GitLab Flow (develop → preprod → main).
- **Qualité** : pre-commit (fmt, validate, tflint, checkov) avant chaque commit.

## Licence

Projet pédagogique — Bachelor CPI, 2026. Données et identifiants fictifs.
