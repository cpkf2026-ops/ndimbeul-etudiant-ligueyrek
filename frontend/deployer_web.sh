#!/usr/bin/env bash
# Construit l'application Flutter web et la publie dans backend/public/app (servie par Laravel
# sur http://localhost:8000/app/).
#
#   bash deployer_web.sh            construit puis publie
#   bash deployer_web.sh --versionner-seulement   ajoute seulement le numéro de version à la
#                                                 version déjà publiée
#
# Numéro de version : le serveur de Laravel n'envoie aucune consigne de cache ; Chrome pouvait
# donc réafficher l'ancienne application après une mise à jour (observé le 30/10/2026). Les
# fichiers de démarrage sont appelés avec « ?v=<numéro> » : à chaque publication, l'adresse
# change et le navigateur télécharge forcément la nouvelle version.
set -euo pipefail
cd "$(dirname "$0")"
CIBLE=../backend/public/app

versionner() {
  local dossier=$1 version
  version=$(date +%Y%m%d%H%M%S)
  sed -i -E "s#\"mainJsPath\":\"main\.dart\.js[^\"]*\"#\"mainJsPath\":\"main.dart.js?v=${version}\"#" "$dossier/flutter_bootstrap.js"
  sed -i -E "s#src=\"flutter_bootstrap\.js[^\"]*\"#src=\"flutter_bootstrap.js?v=${version}\"#" "$dossier/index.html"
  echo "Version ${version}"
}

if [ "${1:-}" = "--versionner-seulement" ]; then
  versionner "$CIBLE"
  exit 0
fi

# MSYS_NO_PATHCONV : sinon Git Bash transforme « /app/ » en chemin Windows.
MSYS_NO_PATHCONV=1 flutter build web --release --base-href /app/
if [ ! -f build/web/index.html ] || ! grep -q 'base href="/app/"' build/web/index.html; then
  echo "Construction incomplète : la version en ligne n'est pas modifiée." >&2
  exit 1
fi
versionner build/web
rm -rf "${CIBLE}_ancienne"
mv "$CIBLE" "${CIBLE}_ancienne"
cp -r build/web "$CIBLE"
rm -rf build "${CIBLE}_ancienne"
echo "Application publiée dans backend/public/app"
