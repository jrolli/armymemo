# Build the example memos with typst. The only tool required is `typst`.
#
# Each examples/*.typ imports the package entrypoint (/lib.typ) and applies
# `#show: memo.with(..)`. `--root .` lets the document resolve /lib.typ and the
# bundled seal image from the repository root.

TYPST ?= typst

SOURCES := $(wildcard examples/*.typ)
PDFS    := $(patsubst examples/%.typ,build/%.pdf,$(SOURCES))
FIELDS  := $(patsubst examples/%.typ,build/%.fields.json,$(SOURCES))

.PHONY: all clean
all: $(PDFS) $(FIELDS)

build/%.pdf: examples/%.typ lib.typ DOD_Seal_BW.png | build
	$(TYPST) compile --root . $< $@

# Signature/concurrence box positions for the esign tool, one JSON array per
# memo (see esign-field in lib.typ). Requires typst >= 0.15; on older typst use
# `typst query --root . $< "<esign-field>" --field value` instead.
build/%.fields.json: examples/%.typ lib.typ DOD_Seal_BW.png | build
	$(TYPST) eval 'query(<esign-field>).map(it => it.value)' --in $< --root . --format json > $@

build:
	mkdir -p build

clean:
	rm -rf build
