#!/bin/bash

COURS_DIR=cours
IMG_DIR=images
LIST=cours.json
LANGUAGE=fr
FALLBACK_LANGUAGE=fr

TITLE=""
DATE=""

DOCKER_TAG=$(printenv DOCKER_TAG)

if [ -z ${DOCKER_TAG} ]; then
  DOCKER_TAG="stable"
fi

build-html() {
  mkdir -p output-html/revealjs/css/theme
  mkdir -p output-html/images

  cp styles/"$THEME".css output-html/revealjs/css/theme/"$THEME".css
  cp -r images/* output-html/images/

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
    docker run -v $PWD:/formations osones/revealjs-builder:"$DOCKER_TAG" \
      --standalone \
      --template=/formations/templates/template.revealjs \
      --slide-level 3 \
      -V theme="$THEME" \
      -V navigation=frame \
      -V revealjs-url="$REVEALJSURL" \
      -V slideNumber=true \
      -V title="$TITLE" \
      -V institute=Osones \
      -o /formations/output-html/"$cours"."$LANGUAGE".html \
      /formations/"$COURS_DIR"/slide-"$cours"
    rm -f "$COURS_DIR"/slide-"$cours"
  done
}

build-pdf() {
  mkdir -p output-pdf
  for cours in $((jq keys | jq -r '.[]') < $LIST); do
    docker run \
      -v $PWD/output-pdf:/output \
      -v $PWD/output-html/"$cours"."$LANGUAGE".html:/index.html \
      -v $PWD/images:/images osones/wkhtmltopdf:$DOCKER_TAG \
          -O landscape \
          -s A5 \
          -T 0 file:///index.html\?print-pdf /output/"$cours"."$LANGUAGE".pdf
  done
}

display_help() {
  cat <<EOF

  USAGE : $0 options

    -o output           Output format (html, pdf or all). Default: all

    -t theme            Theme to use. Default: osones

    -u revealjsURL      RevealJS URL that need to be use. If you build formation
                        supports on local environment you should use "." and git
                        clone http://github.com/hakimel/reveal.js and put your
                        index.html into the repository clone.
                        This option is also necessary even if you only want PDF
                        output. Default: https://osones.com/revealjs

    -c course           Courses to build, if not specified all courses are built

    -l language         Language in which you want the course to be built. Default: fr
EOF

exit 0
}

while getopts ":o:t:u:c:l:h" OPT; do
    case $OPT in
        h) display_help ;;
        c) COURSE="$OPTARG";;
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

[[ $REVEALJSURL == "" ]] && REVEALJSURL="https://osones.com/revealjs"
if [[ $THEME == "" ]]; then
  THEME="osones"
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

OUTPUT=${OUTPUT:-all}
if [[ ! $OUTPUT =~ html|pdf|all ]]; then
    echo "Invalid option: either html, pdf or all" >&2
    display_help
    exit 1
elif [[ $OUTPUT == "html" ]]; then
    build-html
elif [[ $OUTPUT == "pdf" || $OUTPUT == "all" ]]; then
    build-html
    build-pdf
fi
rm -f cours.json.tmp
