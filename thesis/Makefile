TEXC=pdflatex
CFLAGS=-interaction=nonstopmode -halt-on-error -file-line-error
BIBC=bibtex
PAPER=thesis
BIBLIO=references
EXAMPLES=sourcecode/coin.links ../programs/links/concur_model.links ../programs/links/links_concur_model.links
LINKS=$(HOME)/projects/links/compiler/links
LFLAGS=--config=$(HOME)/projects/links/compiler/default.config
LINKSC=$(LINKS) -c --native

all: $(PAPER).pdf

program_outputs: sourcecode/coin.links
	mkdir -p outputs
	$(LINKS) $(LFLAGS) $(EXAMPLES) > output.tmp
	bash mksnippets.sh output.tmp outputs

snippets: $(EXAMPLES)
	mkdir -p snippets
	$(foreach src,$(EXAMPLES),bash mksnippets.sh $(src) snippets;)

$(PAPER).aux: $(PAPER).tex
	$(TEXC) $(CFLAGS) $(PAPER)

$(BIBLIO).bbl: $(PAPER).aux $(BIBLIO).bib
	$(TEXC) $(CFLAGS) $(PAPER)
	$(BIBC) $(PAPER)

$(PAPER).pdf: program_outputs snippets $(PAPER).aux $(BIBLIO).bbl 
	$(TEXC) $(CFLAGS) $(PAPER)
	$(TEXC) $(CFLAGS) $(PAPER)

camera-ready: all
	$(LINKS) $(LFLAGS) $(EXAMPLES)

clean:
	rm -f *.log *.aux *.toc *.out
	rm -f *.bbl *.blg *.fls *.xml
	rm -f *.fdb_latexmk
	rm -f $(PAPER).pdf
	rm -f *.o *.cmx *.cmo
	rm -rf snippets
	rm -rf outputs
	rm -f output.tmp

.PHONY: all camera-ready clean
