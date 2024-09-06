FROM nginx:alpine
COPY --chown=42:42 output-html/* /usr/share/nginx/html/.
