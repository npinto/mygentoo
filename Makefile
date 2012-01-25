
default: portage-dirs

# -- Portage
portage-dirs:
	mkdir -p ${EPREFIX}/etc/portage/package.use
	mkdir -p ${EPREFIX}/etc/portage/package.keywords
	mkdir -p ${EPREFIX}/etc/portage/package.mask
	mkdir -p ${EPREFIX}/etc/portage/package.unmask

eix:
	emerge -uN -j app-portage/eix
	cp -vf {files,${EPREFIX}}/etc/eix-sync.conf
	eix-sync -q

# -- System
parallel: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/parallel
	emerge -uN -j sys-process/parallel

# -- Editors
vim: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/vim
	emerge -uN -j app-editors/vim

gvim: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/gvim
	emerge -uN -j app-editors/gvim

# -- python
ipdb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipdb
	emerge -uN -j dev-python/ipdb

scikits.learn: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/scikits.learn
	emerge -uN -j sci-libs/scikits_learn

pytables: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pytables
	emerge -uN -j dev-python/pytables

pymongo: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pymongo
	emerge -uN -j dev-python/pymongo

# -- C/C++
tbb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/tbb
	emerge -uN -j dev-cpp/tbb

# -- Database
mongodb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/mongodb
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/mongodb
	emerge -uN -j dev-db/mongodb
