
# -- Portage
portage-dirs:
	mkdir -p ${EPREFIX}/etc/portage/package.use
	mkdir -p ${EPREFIX}/etc/portage/package.keywords
	mkdir -p ${EPREFIX}/etc/portage/package.mask
	mkdir -p ${EPREFIX}/etc/portage/package.unmask

eix:
	emerge -uN -j app-portage/eix
	cp -vf {files,${EPREFIX}}/etc/eix-sync.conf
	eix-sync

# -- Editors
vim: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/vim
	cat ${EPREFIX}/etc/portage/package.use/vim
	emerge -uN -j app-editors/vim

gvim: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/gvim
	cat ${EPREFIX}/etc/portage/package.use/gvim
	emerge -uN -j app-editors/gvim

# -- python
ipdb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipdb
	pip uninstall -y ipdb || exit 0
	emerge -uN -j dev-python/ipdb

scikits.learn: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/scikits.learn
	pip uninstall -y scikits.learn || exit 0
	emerge -uN -j sci-libs/scikits_learn

pytables: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pytables
	pip uninstall -y pytables || exit 0
	emerge -uN -j dev-python/pytables
