
default: portage-dirs

# -- Portage
portage-dirs:
	@mkdir -p ${EPREFIX}/etc/portage/package.use
	@mkdir -p ${EPREFIX}/etc/portage/package.keywords
	@mkdir -p ${EPREFIX}/etc/portage/package.mask
	@mkdir -p ${EPREFIX}/etc/portage/package.unmask

eix:
	emerge -uN -j app-portage/eix
	cp -vf {files,${EPREFIX}}/etc/eix-sync.conf
	eix-sync -q

# -- System
parallel: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/parallel
	emerge -uN -j sys-process/parallel

wgetpaste:
	cp -vf {files,${EPREFIX}}/etc/wgetpaste.conf
	emerge -uN -j app-text/wgetpaste

# -- Editors
vim: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/vim
	emerge -uN -j app-editors/vim

gvim: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/gvim
	emerge -uN -j app-editors/gvim

# -- Python
ipython: portage-dirs pyqt4
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/ipython
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipython
	emerge -uN -j dev-python/ipython

ipdb: portage-dirs ipython
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipdb
	emerge -uN -j dev-python/ipdb

scikits.learn: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/scikits.learn
	emerge -uN -j sci-libs/scikits_learn

scikits.image: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/scikits.image
	emerge -uN -j sci-libs/scikits_image

pytables: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pytables
	emerge -uN -j dev-python/pytables

pymongo: portage-dirs mongodb
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pymongo
	emerge -uN -j dev-python/pymongo

pyqt4: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/pyqt4
	emerge -uN -j dev-python/PyQt4

pip: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/pip
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pip
	emerge -uN -j dev-python/pip

virtualenv: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/virtualenv
	emerge -uN -j dev-python/virtualenv

pycuda: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pycuda
	emerge -uN -j dev-python/pycuda

# -- C/C++
tbb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/tbb
	emerge -uN -j dev-cpp/tbb

# -- Database
mongodb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/mongodb
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/mongodb
	emerge -uN -j dev-db/mongodb

# -- Image
imagemagick: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/imagemagick
	emerge -uN -j media-gfx/imagemagick

# -- Misc
shogun: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/shogun
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/shogun
	-layman -a sekyfsr
	emerge -uN -j sci-libs/shogun

# -- CUDA
nvidia-drivers:
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/nvidia-drivers
	emerge -uN -j x11-drivers/nvidia-drivers

cuda:
	-layman -a sekyfsr
	eix-sync -q
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/cuda
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/cuda
	emerge -uN -j dev-util/nvidia-cuda-toolkit
	emerge -uN -j dev-util/nvidia-cuda-sdk
