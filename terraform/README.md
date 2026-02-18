# Terraform — Infrastructure Azure

- `modules/` : modules réutilisables (aks, postgresql, keyvault, ...).
- `envs/prod/` : composition de l'environnement de production.

```bash
cd envs/prod
cp terraform.tfvars.example terraform.tfvars   # renseigner vos valeurs
terraform init && terraform plan -out plan.tfplan
terraform apply plan.tfplan
```
État distant : Azure Storage (versioning + lock natif). Voir `backend.tf`.
