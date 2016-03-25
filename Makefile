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

# Definition of cours based on modules
cours=cours/list.md
# Where to get revealjs stuff
revealjsurl=http://formation.osones.com/revealjs

# Define "all", which is built by default
all: openstack.pdf docker.pdf

build/Makefile:
	mkdir -p build
	sed -E 's#^(.*):(.*)#build/\1.md: $$(addprefix cours/, \2)\n\t$$(foreach module,$$^,cat $$(module) >> $$@;)#' $(cours) > build/Makefile

-include build/Makefile

build/%.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -V navigation=frame
	sed -i 's,\\{width=``.*},,' $@ # workaround
	sed -i 's,\\{height=``.*},,' $@

build/%-handout.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -V navigation=frame -V handout
	sed -i 's,\\{width=``.*},,' $@
	sed -i 's,\\{height=``.*},,' $@

%.html: build/%.md
	pandoc $< -t revealjs -f markdown -s -o $@ --slide-level 3 -V navigation=frame -V revealjs-url=$(revealjsurl)

%.pdf: build/%.tex
	pdflatex -output-directory build/ $<
	pdflatex -output-directory build/ $<
	mv build/$@ $@

%-print.pdf: %.pdf
	pdfnup --nup 2x2 --frame true --suffix print $<

clean:
	rm -rf build/

mrproper: clean
	rm -f *.pdf
	rm -f *.html
