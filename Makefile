TEXFILES = main.tex

all: screen.pdf handout.pdf print.pdf

%.pdf: %.tex $(TEXFILES)
	pdflatex $<
	pdflatex $<

clean:
	rm -f {screen,handout,print}.{aux,log,nav,out,snm,toc}

mrproper: clean
	rm -f {screen,handout,print}.pdf
