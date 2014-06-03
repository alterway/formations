#TEXFILES = latex/main.tex

all: screen.pdf handout.pdf print.pdf

#%.pdf: latex/%.tex $(TEXFILES)
%.pdf: latex/%.tex
	pdflatex $<
	pdflatex $<

clean:
	rm -f {screen,handout,print}.{aux,log,nav,out,snm,toc}

mrproper: clean
	rm -f {screen,handout,print}.pdf
