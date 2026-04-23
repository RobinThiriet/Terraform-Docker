# Architecture

## Vue d'ensemble

Le projet deploie une petite plateforme locale `local-platform` composee de quatre services relies par un reseau Docker dedie :

- `reverse-proxy` : point d'entree HTTP
- `frontend` : site statique servi par Nginx
- `backend` : API Python minimaliste
- `redis` : cache et compteur de requetes

Terraform orchestre l'ensemble via le provider Docker et un module reutilisable situe dans `modules/local_platform`.

## Composants

### Reverse proxy

Le reverse proxy Nginx expose le port HTTP principal du projet.

- route `/` vers le frontend
- route `/api/*` vers le backend
- expose `/healthz` pour les checks simples
- ecrit ses logs dans un volume Docker persistant

### Frontend

Le frontend est une page statique servie par un container Nginx.

- affiche une interface simple
- appelle `/api/info` pour recuperer l'etat du backend
- peut etre expose directement en `dev` pour faciliter les tests

### Backend

Le backend est une petite application Python.

- expose `/healthz`
- expose `/api/info`
- lit ses variables d'environnement
- contacte Redis pour verifier la connectivite et incrementer un compteur

### Redis

Redis joue ici le role de cache local.

- fonctionne sur le reseau Docker partage
- stocke un compteur de requetes
- persiste ses donnees dans un volume Docker

## Reseau et persistance

Le module cree :

- un reseau Docker dedie par environnement
- un volume pour Redis
- un volume pour les logs du reverse proxy

Pattern de nommage :

- reseau : `local-platform-<env>-network`
- volumes : `local-platform-<env>-redis-data` et `local-platform-<env>-proxy-logs`
- containers : `local-platform-<env>-<service>`

## Environnements

Deux fichiers de variables sont fournis :

- `env/dev.tfvars`
- `env/prod.tfvars`

Differences principales :

- `dev` expose des ports directs pour le frontend, le backend et Redis
- `prod` n'expose que le reverse proxy

## Flux applicatif

1. L'utilisateur appelle `http://localhost:<port>`.
2. Le reverse proxy recoit la requete.
3. La racine `/` est envoyee vers le frontend.
4. Les appels `/api/*` sont envoyes vers le backend.
5. Le backend contacte Redis sur le reseau Docker interne.

## Healthchecks

Chaque service possede un healthcheck :

- `frontend` : verification HTTP locale via `wget`
- `backend` : verification de `/healthz`
- `reverse-proxy` : verification de `/healthz`
- `redis` : verification `redis-cli ping`

## Choix techniques

Pourquoi cette structure :

- garder un root Terraform simple a lire
- isoler la logique reusable dans un module
- montrer des dependances concretes entre services
- separer clairement les parametres d'environnement
- rester assez leger pour tourner en local rapidement

