# Kubernetes (AKS)

- `policies/` : NetworkPolicies deny-by-default + flux autorisés (HDS).
- `cronjobs/` : job d'anonymisation k-anonymat nocturne.
- `rbac/` : mapping groupes Entra ID -> rôles (PIM pour les admins).

```bash
kubectl apply -f policies/
kubectl apply -f rbac/
kubectl apply -f cronjobs/
```
