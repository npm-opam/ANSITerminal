
PKGNAME	    = $(shell oasis query name)
PKGVERSION  = $(shell oasis query version)
PKG_TARBALL = $(PKGNAME)-$(PKGVERSION).tar.gz

DISTFILES   = _oasis _tags Makefile \
	$(wildcard $(addprefix src/, *.ml *.mli *.c)) \
	$(wildcard *.ml) $(wildcard examples/)

WEB = shell.forge.ocamlcore.org:/home/groups/ansiterminal/htdocs

.PHONY: all byte native configure doc install uninstall reinstall upload-doc

all byte native setup.log: setup.data
	ocaml setup.ml -build

configure: setup.data
setup.data: setup.ml $(wildcard $(addprefix src/, *.ml *.mli *.c))
	ocaml setup.ml -configure --enable-tests

setup.ml: _oasis
	oasis setup -setup-update dynamic

doc install uninstall reinstall: setup.log
	ocaml setup.ml -$@

upload-doc: doc
	scp -C -p -r _build/API.docdir $(WEB)

test: all
	CAML_LD_LIBRARY_PATH=_build/src/ ./test.byte 


# Make a tarball
.PHONY: dist tar
dist tar: $(DISTFILES)
	@ if [ -z "$(PKGNAME)" ]; then echo "PKGNAME not defined"; exit 1; fi
	@ if [ -z "$(PKGVERSION)" ]; then \
		echo "PKGVERSION not defined"; exit 1; fi
	mkdir $(PKGNAME)-$(PKGVERSION)
	cp -p --parents --dereference $(DISTFILES) $(PKGNAME)-$(PKGVERSION)/
#	Make a setup.ml that does not need oasis.
	cd $(PKGNAME)-$(PKGVERSION) && oasis setup
	tar -zcvf $(PKG_TARBALL) $(PKGNAME)-$(PKGVERSION)
	rm -rf $(PKGNAME)-$(PKGVERSION)


.PHONY: clean distclean
clean::
	ocaml setup.ml -clean
	$(RM) $(PKG_TARBALL) setup.data

distclean:
	ocaml setup.ml -distclean
	$(RM) $(wildcard *.ba[0-9] *.bak *~ *.odocl)
