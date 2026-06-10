# Nginx CI/CD Demo

TP CI/CD — pipeline GitHub Actions pour une application Nginx conteneurisée.
Couvre les **niveaux 1 à 3** (Novice → Engineer → Architect).

## Schéma du pipeline

```
                  ┌──────────────────────── job: build-test ────────────────────────┐
  push / PR  ───► │ Checkout → Vérif fichiers → Build Docker → nginx -t → run         │
   (main)         │          → test HTTP / (200) → test /health (200) → cleanup       │
                  └──────────────────────────────┬───────────────────────────────────┘
                                                  │ (succès + push sur main)
                                                  ▼
                  ┌──────────────────────── job: publish ───────────────────────────┐
                  │  Validation manuelle (environment: production)                    │
                  │  → Login GHCR → Build & Push image                                │
                  │     tags : <commit-sha> + latest                                  │
                  └───────────────────────────────────────────────────────────────────┘
```

## Contenu du projet

| Fichier | Rôle |
|---------|------|
| `index.html` | Page statique servie par Nginx |
| `default.conf` | Config Nginx + endpoint `/health` |
| `Dockerfile` | Image basée sur `nginx:alpine` |
| `.github/workflows/ci.yml` | Pipeline CI/CD |

## Détail des niveaux

**Niveau 1 — Novice**
- Build de l'image Docker
- Vérification de la présence des fichiers essentiels
- Test de la configuration Nginx (`nginx -t`)
- Si on casse volontairement `default.conf`, l'étape `nginx -t` échoue et le pipeline passe au rouge.

**Niveau 2 — Engineer**
- Déclenchement sur `push` **et** `pull_request` vers `main`
- Le conteneur est lancé et on teste qu'il répond en HTTP (`/` → 200)
- Test de l'endpoint `/health` (→ 200)
- **Aucun secret** dans le code ou les logs (le seul secret utilisé est `GITHUB_TOKEN`, fourni et chiffré par GitHub, jamais affiché).

**Niveau 3 — Architect**
- Publication de l'image dans **GitHub Container Registry** (`ghcr.io`)
- Tag d'image basé sur le **commit SHA** (`${{ github.sha }}`) + `latest`
- **Validation manuelle** avant déploiement via `environment: production`
  (à protéger dans *Settings → Environments → production → Required reviewers*).

## Tester en local

```bash
docker build -t nginx-ci-demo .
docker run --rm nginx-ci-demo nginx -t
docker run -d --name nginx-test -p 8080:80 nginx-ci-demo
curl http://localhost:8080/          # 200
curl http://localhost:8080/health    # ok
docker rm -f nginx-test
```

## Récupérer l'image publiée (après push sur main)

```bash
docker pull ghcr.io/<user>/nginx-ci-demo:latest
```
