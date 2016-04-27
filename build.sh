#!/bin/bash -xe

#########
# USAGE
########

# ./build.sh COURSE (pdf | html) (RevealjsURL) (theme)

COURS_DIR=cours
IMG_DIR=images
LIST=cours.list
#mode=$1
EXT=$2
COURSE=$1
urlRevealjs=$3
THEME=$4
TITLE=""
DATE=""

# $1 : urlRevealJS
# $2 : theme
function build-html {
  mkdir -p output-html/revealjs/css/theme
  mkdir -p output-html/images

  if [[ $1 != "" ]]; then
    urlRevealjs=$1
  else
    urlRevealjs="http://formations.osones.com/revealjs"
  fi

  if [[ $2 != "" ]]; then
    THEME=$2
  else
    THEME="osones"
  fi

  cp $COURS_DIR/styles/"$THEME".css output-html/revealjs/css/theme/"$THEME".css
  cp -r images/* output-html/images/

  while IFS=$ read cours titre modules; do
    for module in $modules; do
      cat $COURS_DIR/$module >> $COURS_DIR/slide-$cours
    done
    TITLE=$titre

    # Header2 are only usefull for beamer, they need to be replace with Header3 for revealjs interpretation
    sed 's/^## /### /' $COURS_DIR/slide-$cours > tmp_slide-$cours
    mv tmp_slide-$cours $COURS_DIR/slide-$cours

    docker run -v $PWD:/formations osones/revealjs-builder:stable --standalone --template=/formations/templates/template.revealjs --slide-level 3 -V theme=$THEME -V navigation=frame -V revealjs-url=$urlRevealjs -V slideNumber=true -V title="$TITLE" -V institute=Osones -o /formations/output-html/"$cours".html /formations/$COURS_DIR/slide-$cours
    rm -f $COURS_DIR/slide-$cours
  done < $LIST
}
function build-pdf {
  mkdir -p output-pdf
  for cours in $(cut -d$ -f1 $LIST); do
    docker run -v $PWD/output-pdf:/output -v $PWD/output-html/"$cours".html:/index.html -v $PWD/images:/images osones/wkhtmltopdf:stable -O landscape -s A5 -T 0 file:///index.html\?print-pdf /output/"$cours".pdf
  done
}

display_help() {
    cat <<EOF
USAGE : $0 options

-o output           Type of output you desire (html or pdf), if non precised all outputs are built
-t theme            Theme to use
-u revealjsURL      RevealJS URL that need to be use. If you build formation supports on local environment
                    you should use "." and git clone http://github.com/hakimel/reveal.js and put your index.html into the repository clone.
                    This option is also necessary even if you only want PDF output
-c course           Course to  built (doesn't work, all courses are built)

EOF

exit 0

}

while getopts ":o:t:u:c:h" OPT; do
    case $OPT in
        h) display_help ;;
        c) COURSE="$OPTARG";;
        o) OUTPUT="$OPTARG";;
        t) THEME="$OPTARG";;
        u) REVEALJSURL="$OPTARG";;
        ?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

if [[ ! $OUTPUT =~ html|pdf|all ]]; then
    echo "Invalid option: either html, pdf or all" >&2
    exit 1
elif [[ $OUTPUT == "html" ]]; then
    build-html $REVEALJSURL $THEME
elif [[ $OUTPUT == "pdf" || $OUTPUT == "all" ]]; then
    build-html $REVEALJSURL $THEME
    build-pdf
fi
