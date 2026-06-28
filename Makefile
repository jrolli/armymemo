# Build the example memos with typst. The only tool required is `typst`.
#
# Each examples/*.typ imports the package entrypoint (/lib.typ) and applies
# `#show: memo.with(..)`. `--root .` lets the document resolve /lib.typ and the
# bundled seal image from the repository root.

TYPST ?= typst

SOURCES := $(wildcard examples/*.typ)
PDFS    := $(patsubst examples/%.typ,build/%.pdf,$(SOURCES))

.PHONY: all clean
all: $(PDFS)

build/%.pdf: examples/%.typ lib.typ DOD_Seal_BW.png | build
	$(TYPST) compile --root . $< $@

build:
	mkdir -p build

clean:
	rm -rf build
