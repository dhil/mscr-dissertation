CC=pdflatex
CFLAGS=-interaction=nonstopmode -halt-on-error -file-line-error

all: thesis.pdf

snippets:
	echo "I will eventually use this rule to generate code snippets" 
	#mkdir -p snippets
	#bash mksnippets.sh <source.links> snippets

thesis.aux: thesis.tex
	$(CC) $(CFLAGS) thesis

references.bbl: thesis.aux references.bib
	$(CC) $(CFLAGS) thesis
	bibtex thesis

thesis.pdf: snippets thesis.aux references.bbl 
	$(CC) $(CFLAGS) thesis
	$(CC) $(CFLAGS) thesis

# Compiles paper and tests all the code
#camera-ready: nim.links paper.pdf
#	$(HOME)/projects/links/links --config=$(HOME)/projects/links/default.config nim.links

clean:
	rm -f *.log *.aux *.toc *.out
	rm -f *.bbl *.blg *.fls *.xml
	rm -rf snippets
