# Reprendre b et déployer avec Compose

frontal:
  image: osones/nginx:centrale
  ports:
    - "80"
    - "443"
  environment:
    SERVICE_NAME: nginx
  volumes:
    - "/srv/nginx/etc/sites-enabled:/etc/nginx/sites-enabled"
    - "/srv/nginx/etc/certs:/etc/nginx/certs"
    - "/srv/nginx/etc/template:/etc/nginx/template"
    - "/srv/nginx/supervisor-consul:/etc/supervisor-consul"

wordpress:
  image: osones/wordpress:centrale
  environment:
    SERVICE_NAME: wordpress
  volumes:
    - "/data/wordpress"
