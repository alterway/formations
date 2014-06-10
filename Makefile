SHELL=/bin/bash

all: screen.pdf handout.pdf print.pdf

%.pdf: latex/%.tex
	mkdir -p result
	pdflatex -output-directory result $<
	pdflatex -output-directory result $<

clean:
	rm -f result/{screen,handout,print}.{aux,log,nav,out,snm,toc}

mrproper: clean
	rm -f result/{screen,handout,print}.pdf
