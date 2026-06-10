FROM nginx:1.27-alpine

# Configuration nginx custom
COPY default.conf /etc/nginx/conf.d/default.conf

# Contenu statique
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

# Healthcheck Docker natif
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD wget -qO- http://localhost/health || exit 1
