cd ~/formations/markdown/docker

[ -f slide ] && rm slide
for i in $(ls *.md | sort); do
  cat $i >> slide
done
pandoc slide -t revealjs -f markdown -s -o index.html --slide-level 3 -V theme=solarized -V navigation=frame -V revealjs-url=.
#pandoc -t beamer slide -o slides.pdf
