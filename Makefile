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

# Dependencies: pandoc (>= 1.16 recommended)
#               texlive-latex-base
#               texlive-latex-extra
#               texlive-extra-utils (pdfnup)

author="Team Osones"
date="$$(date +'%d %B %Y')"

# Where to get revealjs stuff
revealjsurl=http://formation.osones.com/revealjs

# Definition of cours based on modules
cours=cours.list
title="$$(grep ^$* $(cours) | cut -d '$$' -f2)"

help: ##### Show this help
	@fgrep -h "#####" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/#####//'

all: ##### Build all pdf cours
all: openstack.pdf docker.pdf

build/Makefile: $(cours)
	mkdir -p build
	sed -E 's#^(.*)\$$.*\$$(.*)#build/\1.md: $$(addprefix cours/, \2)\n\trm -f $$@\n\t$$(foreach module,$$^,cat $$(module) >> $$@;)#' $(cours) > build/Makefile

-include build/Makefile

build/%.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -V theme=metropolis -H cours/styles/beamer.custom \
		-V title=$(title) -V institute=Osones -V author=$(author) -V date=$(date)

build/%-handout.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -V theme=metropolis -H cours/styles/beamer.custom -V handout \
		-V title=$(title) -V institute=Osones -V author=$(author) -V date=$(date)

%.html: build/%.md ##### Build cours "%" in html/revealjs, optional argument revealjsurl=<url to revealjs>
	sed 's,^## ,### ,' $< > $<-html # revealjs doesn't support 3 levels
	pandoc $<-html -t revealjs -f markdown -s -o $@ --slide-level 3 -V theme=osones \
		-V revealjs-url=$(revealjsurl) -V navigation=frame -V slideNumber="true" \
		-V title=$(title) -V institute=Osones -V author=$(author) -V date="$(date)"

%.pdf: build/%.tex ##### Build cours "%" in beamer/pdf, use %-handout for the handout version
	ln -sf cours/styles/beamer*metropolis.sty .
	pdflatex -output-directory build/ $<
	pdflatex -output-directory build/ $<
	rm -f beamer*metropolis.sty
	mv build/$@ $@

%-print.pdf: %-handout.pdf ##### Build cours "%" in beamer/pdf, print (4 slides / page) version
	pdfnup --nup 2x2 --frame true --suffix print $<
	mv $*-handout-print.pdf $*-print.pdf

clean: ##### Remove build files
	rm -rf build/
	rm -f beamer*metropolis.sty

mrproper: ##### Remove build files and .html/.pdf files
mrproper: clean
	rm -f *.pdf
	rm -f *.html
