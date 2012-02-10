
default: help

help:
	@echo Available targets:
	@echo ------------------
	@./make-list-targets.sh -f Makefile | cut -d':' -f1

# -- Portage
portage-dirs:
	@mkdir -p ${EPREFIX}/etc/portage/package.use
	@mkdir -p ${EPREFIX}/etc/portage/package.keywords
	@mkdir -p ${EPREFIX}/etc/portage/package.mask
	@mkdir -p ${EPREFIX}/etc/portage/package.unmask

layman:
	emerge -uN -j app-portage/layman
	grep -e '^source.*layman.*' /etc/make.conf \
		|| echo "source /var/lib/layman/make.conf" >> /etc/make.conf
	@echo "$(layman -L | wc -l) overlays found"
	layman -S

eix:
	emerge -uN -j app-portage/eix
	cp -vf {files,${EPREFIX}}/etc/eix-sync.conf
	eix-sync -q

# -- System
gcc:
	emerge -uN '=sys-devel/gcc-4.5.3-r1'
	gcc-config -l
	gcc-config x86_64-pc-linux-gnu-4.5.3
	gcc-config -l
	emerge --oneshot libtool

module-rebuild:
	emerge -uN -j sys-kernel/module-rebuild
	module-rebuild populate

# -- Shell tools
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
pip: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/pip
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pip
	emerge -uN -j dev-python/pip

virtualenv: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/virtualenv
	emerge -uN -j dev-python/virtualenv

ipython: portage-dirs pyqt4
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/ipython
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipython
	emerge -uN -j dev-python/ipython

ipdb: portage-dirs ipython
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipdb
	emerge -uN -j dev-python/ipdb

pep8: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pep8
	emerge -uN -j dev-python/pep8

autopep8: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/autopep8
	emerge -uN -j dev-python/autopep8

numpy: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/numpy
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/numpy
	emerge -uN -j --onlydeps dev-python/numpy
	FEATURES=test emerge -uN dev-python/numpy

scipy: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/scipy
	emerge -uN -j --onlydeps sci-libs/scipy
	FEATURES=test emerge -uN sci-libs/scipy

joblib: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/joblib
	emerge -uN -j dev-python/joblib

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

pycuda: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pycuda
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/pycuda
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
shogun: portage-dirs layman
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/shogun
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/shogun
	-layman -a sekyfsr
	emerge -uN -j sci-libs/shogun

dropbox: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/dropbox
	emerge -uN -j net-misc/dropbox
	sysctl -w fs.inotify.max_user_watches=1000000
	grep max_user_watches /etc/sysctl.conf || \
		echo "fs.inotify.max_user_watches = 1000000" >>  /etc/sysctl.conf
	sed -i 's/fs\.inotify\.max_user_watches.*/fs\.inotify\.max_user_watches = 1000000/g' /etc/sysctl.conf

# -- CUDA
nvidia-drivers: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/nvidia-drivers
	emerge -uN -j x11-drivers/nvidia-drivers
	emerge -uN -j app-admin/eselect-opencl
	eselect opencl set nvidia
	eselect opengl set nvidia

cuda: portage-dirs layman nvidia-drivers
	-layman -a sekyfsr
	eix-sync -q
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/cuda
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/cuda
	emerge -uN -j '=dev-util/nvidia-cuda-toolkit-4.1'
	emerge -uN -j '=dev-util/nvidia-cuda-sdk-4.1'
	emerge -uN -j dev-util/nvidia-cuda-tdk
	make module-rebuild
