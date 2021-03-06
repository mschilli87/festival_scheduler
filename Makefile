#######################
# general information #
#######################

# file:         Makefile
# created:      2015-07-23
# last update:  2015-07-27
# author(s):    Marcel Schilling <marcel.schilling@mdc-berlin.de>
# license:      GNU Affero General Public License Version 3 (GNU AGPL v3)
# purpose:      automize generation of festival running orders based on ratings


######################################
# change log (reverse chronological) #
######################################

# 2015-07-27: fixed typo in purpose comment
# 2015-07-23: added usage of CSS style sheet provided by Marta Rodriguez Orejuela to
#             Markdown-to-HTML conversion
#             initial version (running order generation)


####################
# path definitions #
####################

# (absolute) path of this Makefile
MAKEFILE:=$(realpath $(lastword $(MAKEFILE_LIST)))

# (absolute) path of the directory containing this Makefile
MAKEFILE_DIRECTORY:=$(dir $(MAKEFILE))

# (absolute) path of the TSV file with linup & rating information for the festival
FESTIVAL_TSV:=$(MAKEFILE_DIRECTORY)festival.tsv

# (absolute) path of R-Markdown file used to generate the running order
SCHEDULER_RMD:=$(MAKEFILE_DIRECTORY)festival_scheduler.rmd

# (absolute) path of Markdown file containing the running order
FESTIVAL_MD:=$(FESTIVAL_TSV:.tsv=.md)

# (absolute) path of CSS-style-sheet file used for the HTML version of the running order
MARKDOWN_STYLESHEET:=$(MAKEFILE_DIRECTORY)marta.css

# (absolute) path of HTML file containing the running order
FESTIVAL_HTML:=$(FESTIVAL_MD:.md=.html)


#######################
# set make parameters #
#######################

SHELL:=/bin/bash -o pipefail
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


#######################
# program definitions #
#######################

# command used to run R commands
RUN_R_COMMAND:=Rscript -e


##################
# common targets #
##################

# if no target was specified, generate HTML running order
all : $(FESTIVAL_HTML)
.PHONY: all


##########################
# generate running order #
##########################

# define helper macros (see http://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html)
COMMA:=,
SPACE:=
SPACE+=

# define multi-line running order parameters (must not include single-quotes or TABs)
define SCHEDULER_PARAMS
  table_tsv<-"$(FESTIVAL_TSV)"
endef

# define helper variable to use multi-line variable as multi-line string
define newline


endef

# replace newline by semicolon
SCHEDULER_PARAMS:=$(subst $(newline),;,${SCHEDULER_PARAMS})

# knit running order to Markdown passing parameters
$(FESTIVAL_MD) : $(SCHEDULER_RMD) $(FESTIVAL_TSV) | $(dir $(FESTIVAL_MD))
	$(RUN_R_COMMAND) '$(SCHEDULER_PARAMS);require(knitr);knit("$<",output="$@")'

# convert Markdown to HTML
%.html : %.md $(MARKDOWN_STYLESHEET)
	$(RUN_R_COMMAND) 'require(markdown);markdownToHTML("$<","$@",stylesheet="$(word 2,$^)")'
