SHELL=/bin/bash

# Les morceaux que l'on veut inclure
PARTS = common introduction cloud openstack-presentation openstack-deploiement iaas-tirer-partie conclusion
#PARTS = docker-common docker-container docker-base docker-build-ship-run docker-ecosystem docker-hosts
# Par défaut on génère tous les styles : screen, handout et print
all: screen.pdf handout.pdf print.pdf

# Nécessaire pour la suite
pwd:=$(shell pwd)
result:=$(pwd)/result

# Construction du style demandé, avec les morceaux choisis
%.pdf: latex/styles/%.tex latex/*.tex
	$(eval tmp:=$(shell mktemp -d $(pwd)/tmp.XXX))
	cp $< $(tmp)/$*.tex
	$(foreach part,$(PARTS),cat latex/$(part).tex >> $(tmp)/$*.tex;)
	echo '\end{document}' >> $(tmp)/$*.tex
	mkdir -p ${result}
	pdflatex -output-directory $(result) $(tmp)/$*.tex
	pdflatex -output-directory $(result) $(tmp)/$*.tex
	rm -rf $(tmp)
	ln -sf result/$*.pdf $*.pdf

# On ne garde que les PDFs résultants
clean:
	rm -f $(result)/*.{aux,log,nav,out,snm,toc}

# On nettoie tout
mrproper: clean
	rm -rf $(result)/
	rm *.pdf
