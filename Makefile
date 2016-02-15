SHELL=/bin/bash

#### USAGE ####
#
#  make (screen.pdf handout.pdf print.pdf) course=[openstack|docker]
#
#######################

# Par défaut on génère tous les styles : screen, handout et print
all: screen.pdf handout.pdf print.pdf

course=openstack
# Nécessaire pour la suite
pwd:=$(shell pwd)
result:=$(pwd)/result

# Construction du style demandé, avec les morceaux choisis
%.pdf: latex/styles/%.tex latex/${course}/*.tex
	$(eval tmp:=$(shell mktemp -d $(pwd)/tmp.XXX))
	cp $< $(tmp)/$*.tex
	cat latex/${course}/*.tex >> $(tmp)/$*.tex
	echo '\end{document}' >> $(tmp)/$*.tex
	mkdir -p ${result}
	pdflatex -output-directory $(result) $(tmp)/$*.tex
	pdflatex -output-directory $(result) $(tmp)/$*.tex
	rm -rf $(tmp)
	ln -sf result/$*.pdf $*.pdf

# On ne garde que les PDFs résultants
clean:
	rm -f $(result)/*.{aux,log,nav,out,snm,toc}
	rm -rf $(pwd)/tmp.*

# On nettoie tout
mrproper: clean
	rm -rf $(result)/
	rm *.pdf
