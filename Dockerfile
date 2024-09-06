FROM nginx:alpine
COPY --chown=42:42 styles /usr/share/nginx/html/revealjs/css/theme
COPY --chown=42:42 output-html /usr/share/nginx/html
COPY --chown=42:42 images /usr/share/nginx/html/images