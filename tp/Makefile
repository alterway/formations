# Makefile

SOURCE_DOCS := $(filter-out README.md, $(wildcard */*.md))
EXPORTED_DOCS=$(SOURCE_DOCS:.md=.pdf)

OPTIONS=-f markdown+smart --variable fontsize=11pt --variable geometry:"top=2cm, bottom=3cm, left=2cm, right=2cm" --variable geometry:a4paper

%.pdf: %.md
	pandoc $(OPTIONS) -o $@ $<

.PHONY: all clean

all: $(EXPORTED_DOCS)

clean:
	rm -f $(EXPORTED_DOCS)
