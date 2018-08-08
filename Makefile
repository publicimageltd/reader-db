# -*- Makefile -*-
CASK ?= cask

all: test compile

test: clean-elc
	${CASK} exec buttercup -L .

compile:
	${CASK} build

clean-elc:
	${CASK} clean-elc

.PHONY: all test compile clean-elc

