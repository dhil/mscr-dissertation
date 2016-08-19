CC=pdflatex
CFLAGS=-interaction=nonstopmode -halt-on-error -file-line-error


all: ocl2016.pdf

ocl2016.aux: ocl2016.tex
	$(CC) $(CFLAGS) ocl2016

references.bbl: ocl2016.aux references.bib
	$(CC) $(CFLAGS) ocl2016
	bibtex ocl2016

ocl2016.pdf: ocl2016.aux references.bbl 
	$(CC) $(CFLAGS) ocl2016
	$(CC) $(CFLAGS) ocl2016
clean:
	rm -f *.log *.aux *.toc *.out
	rm -f *.bbl *.blg *.fls *.xml
	rm -f *.fdb_latexmk
	rm -f paper.pdf
