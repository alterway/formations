#
#  Usage:
#  make $cours.pdf
#  make $cours-handout.pdf
#  make $cours-print.pdf
#  make $cours.html
#
#  Optional:
#  make build/$cours.md
#  make build/$cours.tex
#

# Dependencies: jq
#               pandoc (>= 1.16 recommended)
#               texlive-latex-base
#               texlive-latex-extra
#               texlive-extra-utils (pdfnup)

# These vars can be overridden
author="Team Osones"
institute="Osones"
date="$$(date +'%d %B %Y')"
lang=fr

# Where to get revealjs stuff
revealjsurl=https://osones.com/formations/revealjs

# Definition of cours based on modules
cours=cours.json
title="$$(jq -r '."$*".course_description' $(cours))"

help: ##### Show this help
	@fgrep -h "#####" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/#####//'

build/cours.list: $(cours)
	mkdir -p build
	jq -r '.[] | [ .course_name, .course_description, .modules[] ] | @tsv' $(cours) | sed 's,\t, ,g3;s,\t,$$,g' > build/cours.list

build/Makefile: build/cours.list
	sed -E 's#^(.*)\$$.*\$$(.*)#build/\1.md: $$(addsuffix .$(lang).md, $$(addprefix cours/, \2))\n\trm -f $$@\n\t$$(foreach module,$$^,cat $$(module) >> $$@;)#' build/cours.list > build/Makefile
	echo >> build/Makefile
	echo -n 'all=' >> build/Makefile
	for i in `cut -d '$$' -f1 build/cours.list`; do echo -n "$$i " >> build/Makefile; done
	echo >> build/Makefile
	for i in `cut -d '$$' -f1 build/cours.list`; do echo "$$i: $(addprefix $$i, .html .pdf -handout.pdf -print.pdf)" >> build/Makefile; done

-include build/Makefile

all: ##### Build all cours in all possible formats
all: $(all)

%: ##### Build cours "%" in all possible formats
%: $(addprefix %, .html .pdf -handout.pdf -print.pdf)

all-html: ##### Build all cours in html/revealjs
all-html: $(addsuffix .html, $(all))

all-pdf: ##### Build all cours in beamer/pdf
all-pdf: $(addsuffix .pdf, $(all)) $(addsuffix -handout.pdf, $(all)) $(addsuffix -print.pdf, $(all))

build/%.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -V theme=metropolis -H styles/beamer.custom \
		-V title=$(title) -V institute=$(institute) -V author=$(author) -V date=$(date)

build/%-handout.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -V theme=metropolis -H styles/beamer.custom -V handout \
		-V title=$(title) -V institute=$(institute) -V author=$(author) -V date=$(date)

%.html: ##### Build cours "%" in html/revealjs, optional argument revealjsurl=<url to revealjs>
%.html: build/%.md
	sed 's,^## ,### ,' $< > $<-html # revealjs doesn't support 3 levels
	pandoc $<-html -t revealjs -f markdown -s -o $@ --slide-level 3 -V theme=osones \
		-V revealjs-url=$(revealjsurl) -V navigation=frame -V slideNumber="true" \
		-V title=$(title) -V institute=$(institute) -V author=$(author) -V date=$(date)

%.pdf: ##### Build cours "%" in beamer/pdf
%.pdf: build/%.tex
	ln -sf styles/beamer*metropolis.sty .
	pdflatex -output-directory build/ $<
	pdflatex -output-directory build/ $<
	rm -f beamer*metropolis.sty
	mv build/$@ $@
%-handout.pdf: ##### Build cours "%" in beamer/pdf, handout version

%-print.pdf: ##### Build cours "%" in beamer/pdf, print (4 slides / page) version
%-print.pdf: %-handout.pdf
	pdfnup --nup 2x2 --frame true --suffix print $<
	mv $*-handout-print.pdf $*-print.pdf

modules.png: ##### Build graph depency of the modules
modules.png:
	dot -Tpng modules.dot > modules.png

clean: ##### Remove build files
	rm -rf build/
	rm -f beamer*metropolis.sty

mrproper: ##### Remove build files and .html/.pdf files
mrproper: clean
	rm -f *.pdf
	rm -f *.html
	rm -f modules.png
