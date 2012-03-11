default: help

help:
	make list

list:
	@#@echo Available targets:
	@#@echo ------------------
	@./make-list-targets.sh -f Makefile | grep -v '_.*' | cut -d':' -f1

all:
	make $(shell make list | grep -v all)

# -- Portage
portage-dirs:
	@mkdir -p ${EPREFIX}/etc/portage/package.use
	@mkdir -p ${EPREFIX}/etc/portage/package.keywords
	@mkdir -p ${EPREFIX}/etc/portage/package.mask
	@mkdir -p ${EPREFIX}/etc/portage/package.unmask
	@mkdir -p ${EPREFIX}/etc/portage/package.license

eix:
	emerge -uN -j app-portage/eix
	cp -vf {files,${EPREFIX}}/etc/eix-sync.conf
	eix-sync -q

layman:
	emerge -uN -j app-portage/layman
	grep -e '^source.*layman.*' /etc/make.conf \
		|| echo "source /var/lib/layman/make.conf" >> /etc/make.conf
	@echo "$(layman -L | wc -l) overlays found"
	layman -S

_overlay:
	layman -l | grep ${OVERLAY} || layman -a ${OVERLAY}
	layman -s ${OVERLAY}
	egencache --repo='sekyfsr' --update
	#eix-update

overlay-sekyfsr: OVERLAY=sekyfsr
overlay-sekyfsr: _overlay

# -- System
gcc: GCC_VERSION=$(shell gcc-config -C -l | grep '*$$' | cut -d' ' -f 3)
gcc:
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/$@
	echo $(GCC_VERSION)
	gcc-config -l
	emerge -uN '=sys-devel/gcc-4.5.3-r2'
	gcc-config x86_64-pc-linux-gnu-4.5.3
	gcc-config -l
	emerge --oneshot libtool

module-rebuild:
	emerge -uN -j sys-kernel/module-rebuild
	module-rebuild populate

# -- Network
bind:
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/bind
	emerge -uN -j net-dns/bind

# -- Shell tools
parallel: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/$@
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

# -- Desktop
xdg:
	command -v xdg-mime &> /dev/null || emerge -uN -j x11-misc/xdg-utils

xdg-config: xdg evince nautilus
	mkdir -p ${HOME}/.local/share/applications/
	xdg-mime default evince.desktop application/pdf
	xdg-mime default nautilus-browser.desktop application/pdf

evince:
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	command -v evince &> /dev/null || emerge -uN -j app-text/evince

nautilus:
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	command -v nautilus &> /dev/null || emerge -uN -j gnome-base/nautilus

terminator: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j x11-terms/terminator

# -- Python
python: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-lang/python

pip: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/pip
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pip
	emerge -uN -j dev-python/pip

setuptools: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/setuptools
	emerge -uN -j dev-python/setuptools

virtualenv: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/virtualenv
	emerge -uN -j dev-python/virtualenv

virtualenvwrapper: portage-dirs virtualenv
	-layman -a sekyfsr
	layman -S
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/virtualenvwrapper
	emerge -uN -j dev-python/virtualenvwrapper

ipython: portage-dirs pyqt4
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/ipython
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipython
	emerge -uN -j dev-python/ipython

ipdb: portage-dirs ipython
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/ipdb
	emerge -uN -j dev-python/ipdb

cython: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/cython
	emerge -uN -j dev-python/cython

pep8: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/pep8
	emerge -uN -j dev-python/pep8

autopep8: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/autopep8
	emerge -uN -j dev-python/autopep8

numpy: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/numpy
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/numpy
	emerge -uN -j dev-python/numpy

scipy: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j sci-libs/scipy

numexpr: portage-dirs mkl
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/numexpr
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/numexpr
	emerge -uN -j --onlydeps dev-python/numexpr
	FEATURES=test emerge -uN dev-python/numexpr

joblib: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/$@
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
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-python/pycuda

pyopencl: portage-dirs opencl
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-python/pyopencl

simplejson: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/simplejson
	emerge -uN -j dev-python/simplejson

fabric: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/fabric
	emerge -uN -j dev-python/fabric

# -- C/C++
icc: portage-dirs overlay-sekyfsr
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/icc
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/icc
	cp -vf {files,${EPREFIX}}/etc/portage/package.license/icc
	emerge -uN dev-lang/icc

tbb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/tbb
	emerge -uN -j dev-cpp/tbb

mkl: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/mkl
	cp -vf {files,${EPREFIX}}/etc/portage/package.license/mkl
	emerge -uN -j sci-libs/mkl

# -- Database
mongodb: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/mongodb
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/mongodb
	emerge -uN -j dev-db/mongodb

# -- Image / Video
freeimage: portage-dirs
	-layman -a gamerlay
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/freeimage
	emerge -uN -j media-libs/freeimage

imagemagick: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/imagemagick
	emerge -uN -j media-gfx/imagemagick

mplayer2: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j media-video/mplayer2

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

# -- OpenCL
opencl: portage-dirs
	cp -vf {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -vf {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -vf {files,${EPREFIX}}/etc/portage/package.license/$@
	emerge -uN -j virtual/opencl

# -- CUDA
nvidia-drivers: portage-dirs gcc
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

# -- Java
${EPREFIX}/usr/portage/distfiles/jdk-6u31-linux-x64.bin:
	wget http://download.oracle.com/otn-pub/java/jdk/6u31-b04/jdk-6u31-linux-x64.bin
	mv -vf jdk-6u31-linux-x64.bin $@

sun-jdk: ${EPREFIX}/usr/portage/distfiles/jdk-6u31-linux-x64.bin
	cp -vf {files,${EPREFIX}}/etc/portage/package.license/$@
	emerge -uN -j dev-java/sun-jdk 

