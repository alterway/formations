# Lancer le conteneur etherpad en y montant un volume

docker run -d \
            -p 80:9001 \
            osones/etherpad:alpine

# Utiliser l'image nginx construite précedemment

docker run -d \
            -p 80:80 \
            -p 443:443 \
            -v /data/nginx/certs:/etc/nginx/certs \
            -v /srv/nginx/etc/sites-enabled:/etc/nginx/sites-enabled \
            -v container-wordpress:/truc # TBC
            osones/nginx:centrale


