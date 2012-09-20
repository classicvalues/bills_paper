# LaTeX Makefile for dvi, ps, and pdf file creation.
# By Jeffrey Humpherys
# Written April 05, 2004
# Revised January 13, 2005
# Thanks Bjorn and Boris
#
# Adapted by Jaume Barcelo
#
# Usage:
# make	  # make dvi, ps, and pdf
# make dvi      # make dvi
# make ps       # make ps (and dvi)
# make pdf      # make pdf
#

MAIN		= barcelo2012mdc
SOURCES		= $(wildcard ./*.tex)
EPSFIGURES	= $(patsubst %.fig,%.eps,$(wildcard ./figures/*.fig))
PDFFIGURES	= $(patsubst %.fig,%.pdf,$(wildcard ./figures/*.fig))

all: bbl dvi pdf

bbl: ${MAIN}.bbl
dvi: ${MAIN}.dvi
pdf: ${MAIN}.pdf
diff: ${MAIN}_diff.pdf

${MAIN}.bbl: my_bib.bib
	latex ${MAIN}
	@while ( grep "Rerun to get cross-references"	\
			${MAIN}.log > /dev/null ); do		\
				echo '** Re-running LaTeX **';		\
		latex ${MAIN};				\
	done
	bibtex ${MAIN}
	latex ${MAIN}
	@while ( grep "Rerun to get cross-references"	\
			${MAIN}.log > /dev/null ); do		\
				echo '** Re-running LaTeX **';		\
		latex ${MAIN};				\
	done
	

${MAIN}.dvi : ${SOURCES} ${EPSFIGURES}
	latex ${MAIN}
	@while ( grep "Rerun to get cross-references"	\
			${MAIN}.log > /dev/null ); do		\
				echo '** Re-running LaTeX **';		\
		latex ${MAIN};				\
	done

${MAIN}.pdf : ${MAIN}.dvi ${EPSFIGURES}
	dvips -o ${MAIN}.ps -Ppdf -G0 -t a4 ${MAIN}.dvi
	ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -dEmbedAllFonts=true ${MAIN}.ps
	evince ${MAIN}.pdf &

${MAIN}_diff.tex: ${SOURCES}
	latexdiff old.tex ${MAIN}.tex > ${MAIN}_diff.tex
	
${MAIN}_diff.dvi : ${MAIN}_diff.tex ${EPSFIGURES}
	latex ${MAIN}_diff
	@while ( grep "Rerun to get cross-references"	\
			${MAIN}_diff.log > /dev/null ); do		\
				echo '** Re-running LaTeX **';		\
		latex ${MAIN}_diff;				\
	done

${MAIN}_diff.pdf : ${MAIN}_diff.dvi ${EPSFIGURES}
	dvips -o ${MAIN}_diff.ps -Ppdf -G0 -t a4 ${MAIN}_diff.dvi
	ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -dEmbedAllFonts=true ${MAIN}_diff.ps
	evince ${MAIN}_diff.pdf &

clean:
	rm -f ./figures/*.tex
	rm -f ./figures/*.bak
	rm -f ./*.aux
	rm -f ./*.tex~
#
# (re)Make .eps is .fig if newer
#
%.eps : %.fig
	#Creates .eps file
	fig2dev -L pstex $*.fig > $*.eps


