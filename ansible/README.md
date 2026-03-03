# Ansible — Configuration des hôtes

```bash
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventories/prod/hosts.yml site.yml
# Rotation des secrets :
ansible-playbook playbooks/rotate-secrets.yml
```
Les secrets sont chiffrés avec `ansible-vault` dans `vault/` (jamais en clair).
