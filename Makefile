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
	@mkdir -p ${EPREFIX}/etc/portage/package.env
	@mkdir -p ${EPREFIX}/etc/portage/env

eix: layman
	emerge -uN -j app-portage/eix
	cp -f {files,${EPREFIX}}/etc/eix-sync.conf
	eix-sync -q

layman:
	emerge -uN -j app-portage/layman
	touch /var/lib/layman/make.conf
	grep -e '^source.*layman.*' /etc/make.conf \
		|| echo "source /var/lib/layman/make.conf" >> /etc/make.conf
	@echo "$(layman -L | wc -l) overlays found"
	layman -S

_overlay:
	layman -l | grep ${OVERLAY} || layman -a ${OVERLAY}
	layman -s ${OVERLAY}
	egencache --repo='sekyfsr' --update

overlay-sekyfsr: OVERLAY=sekyfsr
overlay-sekyfsr: _overlay

# -- System
gcc: GCC_VERSION=$(shell gcc-config -C -l | grep '*$$' | cut -d' ' -f 3)
gcc:
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.unmask/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.env/$@
	cp -f {files,${EPREFIX}}/etc/portage/env/simple-cflags
	# -- gcc-4.5 (default)
	gcc-config -l | grep "x86_64-pc-linux-gnu-4.5.3 \*" &> /dev/null \
		|| \
		(gcc-config -l \
		&& emerge -uN -q '=sys-devel/gcc-4.5.3-r2' \
		&& gcc-config x86_64-pc-linux-gnu-4.5.3 \
		&& gcc-config -l \
		&& emerge --oneshot -q libtool)
	# -- gcc-4.6
	emerge -uN -q '=sys-devel/gcc-4.6.2'
	# -- gcc-4.1
	emerge -uN -q '=sys-devel/gcc-4.1.2'

module-rebuild:
	emerge -uN -j sys-kernel/module-rebuild
	module-rebuild populate

# -- Network
bind:
	cp -f {files,${EPREFIX}}/etc/portage/package.use/bind
	emerge -uN -j net-dns/bind

# -- Shell tools
parallel: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j sys-process/parallel

wgetpaste:
	cp -f {files,${EPREFIX}}/etc/wgetpaste.conf
	emerge -uN -j app-text/wgetpaste

# -- Editors
vim: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/vim
	emerge -uN -j app-editors/vim

gvim: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/gvim
	emerge -uN -j app-editors/gvim

# -- Desktop
gdm: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/etc/conf.d/xdm
	emerge -uN -j gnome-base/gdm

awesome: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/usr/share/xsessions/awesome.desktop
	emerge -uN -j x11-wm/awesome

xdg:
	command -v xdg-mime &> /dev/null || emerge -uN -j x11-misc/xdg-utils

xdg-config: xdg evince nautilus
	mkdir -p ${HOME}/.local/share/applications/
	xdg-mime default evince.desktop application/pdf
	xdg-mime default nautilus-browser.desktop application/pdf

gthumb: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j media-gfx/gthumb

evince: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	command -v evince &> /dev/null || emerge -uN -j app-text/evince

nautilus: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	command -v nautilus &> /dev/null || emerge -uN -j gnome-base/nautilus

gnome-terminal: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j x11-terms/gnome-terminal

terminator: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j x11-terms/terminator

adobe-flash: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.license/$@
	emerge -uN -j www-plugins/adobe-flash

# -- Python
python: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-lang/python
	eselect python set python2.7
	python-updater -- -j --with-bdeps y --keep-going
	emerge --depclean -av -j
	revdep-rebuild -v -- --ask -j

pip: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/pip
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/pip
	emerge -uN -j dev-python/pip

setuptools: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/setuptools
	emerge -uN -j dev-python/setuptools

virtualenv: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/virtualenv
	emerge -uN -j dev-python/virtualenv

virtualenvwrapper: portage-dirs virtualenv
	-layman -a sekyfsr
	layman -S
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/virtualenvwrapper
	emerge -uN -j dev-python/virtualenvwrapper

ipython: portage-dirs pyqt4
	cp -f {files,${EPREFIX}}/etc/portage/package.use/ipython
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/ipython
	emerge -uN -j dev-python/ipython

ipdb: portage-dirs ipython
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/ipdb
	emerge -uN -j dev-python/ipdb

cython: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/cython
	emerge -uN -j dev-python/cython

pep8: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/pep8
	emerge -uN -j dev-python/pep8

autopep8: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/autopep8
	emerge -uN -j dev-python/autopep8

numpy: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/numpy
	cp -f {files,${EPREFIX}}/etc/portage/package.use/numpy
	emerge -uN -j dev-python/numpy

scipy: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j sci-libs/scipy

numexpr: portage-dirs mkl
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/numexpr
	cp -f {files,${EPREFIX}}/etc/portage/package.use/numexpr
	emerge -uN -j --onlydeps dev-python/numexpr
	FEATURES=test emerge -uN dev-python/numexpr

joblib: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j dev-python/joblib

scikits.learn: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/scikits.learn
	emerge -uN -j sci-libs/scikits_learn

scikits.image: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/scikits.image
	emerge -uN -j sci-libs/scikits_image

pytables: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/pytables
	emerge -uN -j dev-python/pytables

pymongo: portage-dirs mongodb
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/pymongo
	emerge -uN -j dev-python/pymongo

pyqt4: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-python/PyQt4

pycuda: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-python/pycuda

pyopencl: portage-dirs opencl
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-python/pyopencl

simplejson: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j dev-python/simplejson

fabric: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j dev-python/fabric

cgkit: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j dev-python/cgkit

# -- C/C++
icc: portage-dirs overlay-sekyfsr
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/icc
	cp -f {files,${EPREFIX}}/etc/portage/package.use/icc
	cp -f {files,${EPREFIX}}/etc/portage/package.license/icc
	emerge -uN dev-lang/icc

tbb: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/tbb
	emerge -uN -j dev-cpp/tbb

mkl: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/mkl
	cp -f {files,${EPREFIX}}/etc/portage/package.license/mkl
	emerge -uN -j sci-libs/mkl

# -- Database
mongodb: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/mongodb
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/mongodb
	emerge -uN -j dev-db/mongodb

# -- Image / Video
freeimage: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/freeimage
	emerge -uN -j media-libs/freeimage

imagemagick: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/imagemagick
	emerge -uN -j media-gfx/imagemagick

mplayer2: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j media-video/mplayer2

# -- Misc
shogun: portage-dirs layman
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/shogun
	cp -f {files,${EPREFIX}}/etc/portage/package.use/shogun
	-layman -a sekyfsr
	emerge -uN -j sci-libs/shogun

dropbox: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j net-misc/dropbox
	sysctl -w fs.inotify.max_user_watches=1000000
	grep max_user_watches /etc/sysctl.conf || \
		echo "fs.inotify.max_user_watches = 1000000" >>  /etc/sysctl.conf
	sed -i 's/fs\.inotify\.max_user_watches.*/fs\.inotify\.max_user_watches = 1000000/g' /etc/sysctl.conf

texlive: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j app-text/texlive-core

cairo: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j x11-libs/cairo

ntfs3g: portage-dirs
	CLEAN_DELAY=0 emerge -q -C sys-fs/ntfsprogs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j sys-fs/ntfs3g

valgrind: portage-dirs
	grep -e '^FEATURES.*=.*splitdebug' /etc/make.conf || echo 'FEATURES="$${FEATURES} splitdebug"' >> /etc/make.conf
	test ! -f /usr/lib/debug/usr/lib64/misc/glibc && emerge -q sys-libs/glibc
	emerge -uN -j dev-util/valgrind

# -- OpenCL
opencl: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.license/$@
	emerge -uN -j virtual/opencl

# -- CUDA
nvidia-drivers: portage-dirs gcc
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j x11-drivers/nvidia-drivers
	eselect opengl set nvidia
	emerge -uN -j app-admin/eselect-opencl
	eselect opencl set nvidia

nvidia-settings: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j media-video/nvidia-settings

cuda: portage-dirs layman nvidia-drivers nvidia-settings
	-layman -a sekyfsr
	eix-sync -q
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/cuda
	cp -f {files,${EPREFIX}}/etc/portage/package.use/cuda
	emerge -uN -j '=dev-util/nvidia-cuda-toolkit-4.1'
	emerge -uN -j '=dev-util/nvidia-cuda-sdk-4.1'
	emerge -uN -j dev-util/nvidia-cuda-tdk
	make module-rebuild

# -- Java
${EPREFIX}/usr/portage/distfiles/jdk-6u31-linux-x64.bin:
	wget http://download.oracle.com/otn-pub/java/jdk/6u31-b04/jdk-6u31-linux-x64.bin
	mv -vf jdk-6u31-linux-x64.bin $@

sun-jdk: ${EPREFIX}/usr/portage/distfiles/jdk-6u31-linux-x64.bin
	cp -f {files,${EPREFIX}}/etc/portage/package.license/$@
	emerge -uN -j dev-java/sun-jdk

