#
#  make $cours.pdf
#  make $cours-handout.pdf
#  make $cours-print.pdf
#
#  Optional:
#  make build/$cours.md
#  make build/$cours.tex
#

cours=cours/list.md

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

%.pdf: build/%.tex
	pdflatex -output-directory build/ $<
	pdflatex -output-directory build/ $<
	cp build/$@ $@

%-print.pdf: %.pdf
	touch $@ #TODO

clean:
	rm -rf build/

mrproper: clean
	rm *.pdf
