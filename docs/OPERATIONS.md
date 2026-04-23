# Exploitation

## Prerequis

- Docker installe et demarre
- Terraform 1.5 ou plus recent

Verifier les versions :

```bash
docker --version
terraform version
```

## Initialisation

Depuis la racine du projet :

```bash
terraform init
```

## Workflow standard

### Environnement de developpement

Plan :

```bash
terraform plan -var-file=env/dev.tfvars
```

Deploiement :

```bash
terraform apply -var-file=env/dev.tfvars
```

Acces :

- reverse proxy : `http://localhost:8080`
- frontend : `http://localhost:18080`
- backend : `http://localhost:18081/api/info`
- redis : `localhost:16379`

### Environnement de production locale

Plan :

```bash
terraform plan -var-file=env/prod.tfvars
```

Deploiement :

```bash
terraform apply -var-file=env/prod.tfvars
```

Acces :

- reverse proxy : `http://localhost:8081`

## Commandes utiles

Lister les ressources Terraform :

```bash
terraform state list
```

Voir les outputs :

```bash
terraform output
```

Voir les containers :

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

Voir les logs du reverse proxy :

```bash
docker logs local-platform-dev-reverse-proxy
```

Voir les logs du backend :

```bash
docker logs local-platform-dev-backend
```

Verifier la sante applicative :

```bash
curl http://localhost:8080/healthz
curl http://localhost:8080/api/info
```

Verifier Redis :

```bash
docker exec -it local-platform-dev-redis redis-cli ping
```

## Destruction

Supprimer l'environnement `dev` :

```bash
terraform destroy -var-file=env/dev.tfvars
```

Supprimer l'environnement `prod` :

```bash
terraform destroy -var-file=env/prod.tfvars
```

## Depannage

### Un port est deja utilise

Symptome :

- `terraform apply` echoue au demarrage d'un container

Actions :

- verifier les ports deja pris avec `ss -lntp`
- modifier les ports dans `env/dev.tfvars` ou `env/prod.tfvars`
- relancer `terraform apply`

### Un container n'est pas healthy

Verifier l'etat :

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}'
```

Consulter les logs :

```bash
docker logs local-platform-dev-frontend
docker logs local-platform-dev-backend
docker logs local-platform-dev-reverse-proxy
docker logs local-platform-dev-redis
```

### Terraform detecte un ecart d'etat

Actions :

- lancer `terraform plan -var-file=env/dev.tfvars`
- verifier les differences
- reappliquer avec `terraform apply -var-file=env/dev.tfvars`

### Nettoyage manuel exceptionnel

Si des ressources Docker existent encore apres un echec :

```bash
docker ps -a
docker volume ls
docker network ls
```

Le nettoyage normal doit rester fait via Terraform.

## Bonnes pratiques

- utiliser `plan` avant `apply`
- versionner `.terraform.lock.hcl`
- ne pas versionner `terraform.tfstate`
- garder les variables d'environnement dans `env/`
- reutiliser le module `modules/local_platform` pour d'autres variantes
