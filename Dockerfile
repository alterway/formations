FROM nginx:alpine

COPY --chown=42:42 output-html /usr/share/nginx/html
COPY --chown=42:42 images /usr/share/nginx/html/images
COPY --chown=42:42 revealjs /usr/share/nginx/html/revealjs
COPY --chown=42:42 styles /usr/share/nginx/html/revealjs/css/theme
RUN <<EOF
    echo '<!DOCTYPE html>' > /usr/share/nginx/html/index.html
    echo '<head>'  >> /usr/share/nginx/html/index.html
    echo '<meta charset="utf-8">' >> /usr/share/nginx/html/index.html
    echo '<title>Index formation</title>' >> /usr/share/nginx/html/index.html
    echo '</head>' >> /usr/share/nginx/html/index.html
    echo '<body>' >> /usr/share/nginx/html/index.html
   
    for i in `ls -1  /usr/share/nginx/html/*.html`
    do
       echo "<a href=$(basename $i)>$(basename $i)</a>"  >> /usr/share/nginx/html/index.html
    done

    echo '</body>' >> /usr/share/nginx/html/index.html
    echo '</html>' >> /usr/share/nginx/html/index.html
EOF
