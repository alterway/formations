#!/bin/bash -xe

#############
#
# If you want to build slides in a local environment, you should use the parameter "./build.sh offline".
# In this way, html files will not fetch their css/js files on Internet.
# You'll need to have a clone of the github repository in order to have css, js and images files
#
# If this build file is used by Travis CI, you can use it as it is.
############

COURS_DIR=cours
IMG_DIR=images
LIST=cours/list.md
mode=$1

mkdir -p $COURS_DIR/output-html/revealjs/css/theme

while IFS=: read cours modules; do
    for module in $modules; do
        cat $COURS_DIR/$module >> $COURS_DIR/slide-$cours
    done
    if [[ $mode == "offline" ]]; then
      pandoc $COURS_DIR/slide-$cours -t revealjs -f markdown -s -o $COURS_DIR/output-html/"$cours".html --slide-level 3 -V theme=osones -V navigation=frame -V revealjs-url=. -V slideNumber="true"
    else
      pandoc $COURS_DIR/slide-$cours -t revealjs -f markdown -s -o $COURS_DIR/output-html/"$cours".html --slide-level 3 -V theme=osones -V navigation=frame -V revealjs-url="http://formation.osones.com/revealjs" -V slideNumber="true"
    fi

    rm -f $COURS_DIR/slide-$cours
done < $LIST

cp $COURS_DIR/styles/osones.css $COURS_DIR/output-html/revealjs/css/theme/osones.css
