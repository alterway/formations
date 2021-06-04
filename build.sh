#!/bin/bash

COURS_DIR=cours
IMG_DIR=images
LIST=cours.json
LANGUAGE=fr
FALLBACK_LANGUAGE=fr
LABS_DIR=labs
LABS_LIST=labs.json

TITLE=""
DATE=""

DOCKER_TAG=$(printenv DOCKER_TAG)

if [ -z ${DOCKER_TAG} ]; then
  DOCKER_TAG="stable"
fi

build-html() {
  mkdir -p output-html
  ln -fs ../images output-html

  echo $REVEALJSURL | grep -q http
  if [ $? == 1 ]; then
    cp styles/"$THEME".css $REVEALJSURL/css/theme/"$THEME".css
    cp -r styles/"$THEME" $REVEALJSURL/css/theme/
  fi

  for cours in $((jq keys | jq -r '.[]') < $LIST); do
    for module in $(jq -r '.["'"$cours"'"].modules[]' $LIST); do
      if [ -f "$COURS_DIR"/"$module"."$LANGUAGE".md ]; then
        cat $COURS_DIR/"$module"."$LANGUAGE".md >> "$COURS_DIR"/slide-"$cours"
      elif [ -f "$COURS_DIR"/"$module"."$FALLBACK_LANGUAGE".md ]; then
        cat "$COURS_DIR"/"$module"."$FALLBACK_LANGUAGE".md >> "$COURS_DIR"/slide-"$cours"
      else
        echo "module "$module" doesn't exist in any of the languages"
      fi
    done
    TITLE=$(jq -r '.["'"$cours"'"].course_name' $LIST)

    # Header2 are only usefull for beamer, they need to be replaced with Header3 for revealjs interpretation
    sed -i 's/^## /### /' "$COURS_DIR"/slide-"$cours"
    echo "Build "$TITLE" "$LANUGAGE" ("$OUTPUT")"
    docker run --rm -v $PWD:/formations alterway/revealjs-builder:"$DOCKER_TAG" \
      --standalone \
      --template=/formations/templates/template.revealjs \
      --slide-level 3 \
      -V theme="$THEME" \
      -V navigation=frame \
      -V revealjs-url="$REVEALJSURL" \
      -V slideNumber=true \
      -V title="$TITLE" \
      -V institute="alter way Cloud Consulting" \
      -o /formations/output-html/"$cours"."$LANGUAGE".html \
      /formations/"$COURS_DIR"/slide-"$cours"
    rm -f "$COURS_DIR"/slide-"$cours"
  done
}

build-html-labs() {
  mkdir -p output-html
  ln -fs ../images output-html

  echo $REVEALJSURL | grep -q http
  if [ $? == 1 ]; then
    cp styles/"$THEME".css $REVEALJSURL/css/theme/"$THEME".css
    cp -r styles/"$THEME" $REVEALJSURL/css/theme/
  fi

  for lab in $((jq keys | jq -r '.[]') < $LIST_LABS); do
    for module in $(jq -r '.["'"$lab"'"].modules[]' $LIST_LABS); do
      if [ -f "$LABS_DIR"/"$module"."$LANGUAGE".md ]; then
        cat $LABS_DIR/"$module"."$LANGUAGE".md >> "$LABS_DIR"/slide-"$lab"
      elif [ -f "$LABS_DIR"/"$module"."$FALLBACK_LANGUAGE".md ]; then
        cat "$LABS_DIR"/"$module"."$FALLBACK_LANGUAGE".md >> "$LABS_DIR"/slide-"$lab"
      else
        echo "module "$module" doesn't exist in any of the languages"
      fi
    done
    TITLE=$(jq -r '.["'"$lab"'"].lab_name' $LIST_LABS)

    # Header2 are only usefull for beamer, they need to be replaced with Header3 for revealjs interpretation
    sed -i 's/^## /### /' "$LABS_DIR"/slide-"$lab"
    echo "Build "$TITLE" "$LANUGAGE" ("$OUTPUT")"
    docker run --rm -v $PWD:/formations alterway/revealjs-builder:"$DOCKER_TAG" \
      --standalone \
      --template=/formations/templates/template.revealjs \
      --slide-level 3 \
      -V theme="$THEME" \
      -V navigation=frame \
      -V revealjs-url="$REVEALJSURL" \
      -V slideNumber=true \
      -V title="$TITLE" \
      -V institute="alter way Cloud Consulting" \
      -o /formations/output-html/"$lab"."$LANGUAGE".html \
      /formations/"$LABS_DIR"/slide-"$lab"
    rm -f "$LABS_DIR"/slide-"$lab"
  done
}




# madnight/docker-alpine-wkhtmltopdf

build-pdf() {
  mkdir -p output-pdf
  for cours in $((jq keys | jq -r '.[]') < $LIST); do
    echo "Generate pdf $cours"
    docker run --rm \
      -v $PWD/output-pdf:/output \
      -v $PWD/output-html/"$cours"."$LANGUAGE".html:/index.html \
      -v $PWD/images:/images alterway/docker-alpine-wkhtmltopdf \
          -q \
          -O landscape \
          -s A5 \
          -T 0 -B 0 file:///index.html\?print-pdf /output/"$cours"."$LANGUAGE".pdf 
  done
}

build-pdf-labs() {
mkdir -p output-pdf
  for lab in $((jq keys | jq -r '.[]') < $LIST_LABS); do
    echo "Generate pdf $lab"
    docker run --rm \
      -v $PWD/output-pdf:/output \
      -v $PWD/output-html/"$lab"."$LANGUAGE".html:/index.html \
      -v $PWD/images:/images alterway/docker-alpine-wkhtmltopdf \
          -q \
          -O portrait \
          -s A5 \
          -T 0 -B 0 file:///index.html\?print-pdf /output/"$lab"."$LANGUAGE".pdf 
  done
}


display_help() {
  cat <<EOF

  USAGE : $0 options

    -o output           Output format (html, pdf or all). Default: all

    -t theme            Theme to use. Default: awcc

    -u revealjsURL      RevealJS URL that need to be use. If you build formation
                        supports on local environment you should git
                        clone https://github.com/hakimel/reveal.js and set
                        this variable to your local copy.
                        This option is also necessary even if you only want PDF
                        output. Default: https://osones.com/formations/revealjs

    -c course           Course to build, "all" for build them all !

    -e lab              Lab to build, "all" for build them all !

    -l language         Language in which you want the course to be built. Default: fr
EOF

exit 0
}

while getopts ":o:t:u:c:l:h" OPT; do
    case $OPT in
        h) display_help ;;
        c) COURSE="$OPTARG";;
        e) LAB="$OPTARG";;
        o) OUTPUT="$OPTARG";;
        t) THEME="$OPTARG";;
        u) REVEALJSURL="$OPTARG";;
        l) LANGUAGE="$OPTARG";;
        ?)
            echo "Invalid option: -$OPTARG" >&2
            display_help
            exit 1
            ;;
    esac
done

#[[ $REVEALJSURL == "" ]] && REVEALJSURL="https://osones.com/formations/revealjs"
#[[ $REVEALJSURL == "" ]] && REVEALJSURL="https://reveal.alterway.fr"
#[[ $REVEALJSURL == "" ]] && REVEALJSURL="http://192.168.1.12:9000"
#[ $REVEALJSURL == "" ]] && REVEALJSURL="http://10.2.1.35:9000"
[[ $REVEALJSURL == "" ]] && REVEALJSURL="https://awformations.s3.eu-west-3.amazonaws.com/formations/revealjs"

if [[ $THEME == "" ]]; then
  THEME="awcc"
else
  ls styles/"$THEME".css &> /dev/null
  [ $? -eq 2 ] && echo "Theme $THEME doesn't exist" && exit 1
fi

if [[ $COURSE != "" ]]; then
  (echo "{ \"$COURSE\":" && jq -r '.["'"$COURSE"'"]' $LIST && echo "}") | jq '.' > cours.json.tmp
  [ $? -eq 1 ] && echo "Course $COURSE doesn't exist, please refer to cours.list" && exit 1
  LIST=cours.json.tmp
else
  LIST=cours.json
fi

if [[ $LAB != "" ]]; then
  (echo "{ \"$LAB\":" && jq -r '.["'"$LAB"'"]' $LIST_LABS && echo "}") | jq '.' > labs.json.tmp
  [ $? -eq 1 ] && echo "Lab $LAB doesn't exist, please refer to labs.list" && exit 1
  LIST_LABS=labs.json.tmp
else
  LIST_LABS=labs.json
fi


OUTPUT=${OUTPUT:-all}
if [[ ! $OUTPUT =~ html|pdf|all ]]; then
    echo "Invalid option: either html, pdf or all" >&2
    display_help
    exit 1
elif [[ $OUTPUT == "html" ]]; then
    build-html
    build-html-labs
elif [[ $OUTPUT == "pdf" || $OUTPUT == "all" ]]; then
    build-html
    build-pdf
    build-pdf-labs
fi
rm -f cours.json.tmp
