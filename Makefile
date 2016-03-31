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

# Dependencies: pandoc
#               pdflatex
#               texlive-extra-utils (pdfnup)

# The following needs to be made variable somehow
title="Formation Osones"
user="Osones"
date="$$(date +%F)"

# Definition of cours based on modules
cours=cours/list.md
# Where to get revealjs stuff
revealjsurl=http://formation.osones.com/revealjs

help: ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

all: ## Build all pdf cours
all: openstack.pdf docker.pdf

build/Makefile:
	mkdir -p build
	sed -E 's#^(.*):(.*)#build/\1.md: $$(addprefix cours/, \2)\n\trm -f $$@\n\t$$(foreach module,$$^,cat $$(module) >> $$@;)#' $(cours) > build/Makefile

-include build/Makefile

build/%.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -H cours/styles/beamer.custom -V theme=metropolis  \
		-V title=$(title) -V institute=Osones -V author=$(user) -V date=$(date)
	sed -i 's,\\{width=``.*},,' $@ # workaround
	sed -i 's,\\{height=``.*},,' $@

build/%-handout.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -H cours/styles/beamer.custom -V theme=metropolis -V handout \
		-V title=$(title) -V institute=Osones -V author=$(user) -V date="$(date)"
	sed -i 's,\\{width=``.*},,' $@
	sed -i 's,\\{height=``.*},,' $@

%.html: build/%.md ## Build cours "%" in html/revealjs, optional argument revealjsurl=<url to revealjs>
	sed 's,^## ,### ,' $< > $<-html # revealjs doesn't support 3 levels
	pandoc $<-html -t revealjs -f markdown -s -o $@ --slide-level 3 -V theme=osones -V navigation=frame -V revealjs-url=$(revealjsurl) -V slideNumber="true" #\
	#	-V title=$(title) -V institute=Osones -V author=$(user) -V date="$(date)"

%.pdf: build/%.tex ## Build cours "%" in beamer/pdf
	ln -s cours/styles/beamer*metropolis.sty .
	pdflatex -output-directory build/ $<
	pdflatex -output-directory build/ $<
	rm beamer*metropolis.sty
	mv build/$@ $@

%-print.pdf: %.pdf ## Build cours "%" in beamer/pdf, print (4 slides / page) version
	pdfnup --nup 2x2 --frame true --suffix print $<

clean: ## Remove build files
	rm -rf build/

mrproper: ## Remove build files and .html/.pdf files
mrproper: clean
	rm -f *.pdf
	rm -f *.html
