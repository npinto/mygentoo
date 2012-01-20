
# -- Portage
portage-dirs:
	mkdir -p ${EPREFIX}/etc/portage/package.use
	mkdir -p ${EPREFIX}/etc/portage/package.keywords
	mkdir -p ${EPREFIX}/etc/portage/package.mask
	mkdir -p ${EPREFIX}/etc/portage/package.unmask

# -- Editors
vim: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/vim
	cat ${EPREFIX}/etc/portage/package.use/vim
	emerge -uN app-editors/vim

gvim: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/gvim
	cat ${EPREFIX}/etc/portage/package.use/gvim
	emerge -uN app-editors/gvim

# -- python
ipdb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipdb
	emerge -uN dev-python/ipdb
