default: help

include init.mk
include machines.mk

help: _list

_list:
	@echo Available targets:
	@echo ------------------
	@./make-list-targets.sh -f Makefile | grep -v '_.*' | cut -d':' -f1

update:
ifeq (${NO_EIX_SYNC},)
	eix-sync -q
endif
	glsa-check -q -t all
	glsa-check -q -f all
ifeq (${NO_ASK},)
	${EMERGE} --ask -qtuDN -q -j --with-bdeps y --keep-going world system
	${EMERGE} --ask --depclean -q # -tv
	revdep-rebuild -q -i -- --ask
else
	${EMERGE} -qtuDN -q -j --with-bdeps y --keep-going world system
	${EMERGE} --depclean -q #-tv
	revdep-rebuild -q -i
endif
	eclean-dist -d
	eclean distfiles
	#eix-test-obsolete
	emaint --check world && emaint --fix world
	dispatch-conf

# -- Portage
portage-dirs:
	@mkdir -p ${EPREFIX}/etc/portage/package.use
	@mkdir -p ${EPREFIX}/etc/portage/package.keywords
	@mkdir -p ${EPREFIX}/etc/portage/package.mask
	@mkdir -p ${EPREFIX}/etc/portage/package.unmask
	@mkdir -p ${EPREFIX}/etc/portage/package.license
	@mkdir -p ${EPREFIX}/etc/portage/package.env
	@mkdir -p ${EPREFIX}/etc/portage/env

autounmask: portage-dirs
	@touch ${EPREFIX}/etc/portage/package.use/z_autounmask
	@touch ${EPREFIX}/etc/portage/package.keywords/z_autounmask
	@touch ${EPREFIX}/etc/portage/package.mask/z_autounmask
	@touch ${EPREFIX}/etc/portage/package.unmask/z_autounmask
	@touch ${EPREFIX}/etc/portage/package.license/z_autounmask
ifeq ($(shell if grep -e '^${EMERGE}_DEFAULT_OPTS = "$${${EMERGE}_DEFAULT_OPTS} --autounmask-write=y"' ${EPREFIX}/etc/make.conf; then echo true; else echo false; fi), false)
	echo '${EMERGE}_DEFAULT_OPTS = "$${${EMERGE}_DEFAULT_OPTS} --autounmask-write=y"' >> ${EPREFIX}/etc/make.conf
endif

portage-sqlite: portage-dirs
	# -- portage sql cache
	# See:
	#  http://en.gentoo-wiki.com/wiki/Portage_SQLite_Cache
	#  http://www.gentoo-wiki.info/TIP_speed_up_portage_with_sqlite
	#  http://forums.gentoo.org/viewtopic.php?t=261580
	grep -e '^FEATURES.*=.*metadata-transfer' ${EPREFIX}/etc/make.conf \
		|| ( \
		${EMERGE} -uN -q -j dev-python/pysqlite \
		&& cp -f {files,${EPREFIX}}/etc/portage/modules \
		&& echo 'FEATURES="$${FEATURES} metadata-transfer"' >> ${EPREFIX}/etc/make.conf \
		&& rm -rf /var/cache/edb/dep \
		&& ${EMERGE} --metadata \
		&& make eix \
		)

eix: portage-dirs layman
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j app-portage/eix
	cp -f {files,${EPREFIX}}/etc/eix-sync.conf
	cp -f {files,${EPREFIX}}/etc/eixrc
	eix-sync -q

layman:
	${EMERGE} -uN -q -j app-portage/layman
	touch /var/lib/layman/make.conf
	grep -e '^source.*layman.*' /etc/make.conf \
		|| echo "source /var/lib/layman/make.conf" >> /etc/make.conf
	@echo "$(layman -L | wc -l) overlays found"
	layman -S

_overlay:
	layman -l | grep ${OVERLAY} || layman -a ${OVERLAY}
	layman -q -s ${OVERLAY}
	egencache --repo=${OVERLAY} --update

overlay-sekyfsr: OVERLAY=sekyfsr
overlay-sekyfsr: _overlay

# -- System
locale:
	cp -f {files,${EPREFIX}}/etc/locale.gen
	cp -f {files,${EPREFIX}}/etc/env.d/02locale
	locale-gen -u
	locale
	env-update && source /etc/profile

#gcc: GCC_VERSION=$(shell gcc-config -C -l | grep '*$$' | cut -d' ' -f 3)
gcc: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.unmask/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.env/$@
	cp -f {files,${EPREFIX}}/etc/portage/env/simple-cflags
	# -- gcc-4.5 (default)
	gcc-config -l | grep "x86_64-pc-linux-gnu-4.5.3 \*" &> /dev/null \
		|| \
		(gcc-config -l \
		&& ${EMERGE} -uN -q '=sys-devel/gcc-4.5.3-r2' \
		&& gcc-config x86_64-pc-linux-gnu-4.5.3 \
		&& gcc-config -l \
		&& ${EMERGE} --oneshot -q libtool)
	#${EMERGE} -uN -q '=sys-devel/gcc-3.4.6-r2'
	#${EMERGE} -uN -q '=sys-devel/gcc-4.1.2'
	${EMERGE} -uN -q '=sys-devel/gcc-4.2.4-r1'
	${EMERGE} -uN -q '=sys-devel/gcc-4.3.6-r1'
	${EMERGE} -uN -q "=sys-devel/gcc-4.4.7"
	${EMERGE} -uN -q '=sys-devel/gcc-4.6.2'

module-rebuild:
	${EMERGE} -uN -q -j sys-kernel/module-rebuild
	module-rebuild populate

# -- Network
bind:
	cp -f {files,${EPREFIX}}/etc/portage/package.use/bind
	${EMERGE} -uN -q -j net-dns/bind

# -- Shell tools
parallel: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j sys-process/parallel

wgetpaste:
	cp -f {files,${EPREFIX}}/etc/wgetpaste.conf
	${EMERGE} -uN -q -j app-text/wgetpaste

# -- Editors
vim: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/vim
	${EMERGE} -uN -q -j app-editors/vim

gvim: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/gvim
	${EMERGE} -uN -q -j app-editors/gvim

# -- Desktop
gdm: portage-dirs xorg-server
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/etc/conf.d/xdm
	${EMERGE} -uN -q -j gnome-base/gdm
	rc-update add xdm default

feh: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j media-gfx/feh

awesome: portage-dirs xorg-server feh
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/usr/share/xsessions/awesome.desktop
	${EMERGE} -uN -q -j x11-wm/awesome
	make fonts

xdg:
	command -v xdg-mime &> /dev/null || ${EMERGE} -uN -q -j x11-misc/xdg-utils

xdg-config: xdg evince nautilus
	mkdir -p ${HOME}/.local/share/applications/
	xdg-mime default evince.desktop application/pdf
	xdg-mime default nautilus-browser.desktop application/pdf

gthumb: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j media-gfx/gthumb

evince: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	command -v evince &> /dev/null || ${EMERGE} -uN -q -j app-text/evince

nautilus: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	command -v nautilus &> /dev/null || ${EMERGE} -uN -q -j gnome-base/nautilus

gnome-terminal: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j x11-terms/gnome-terminal
	make fonts

terminator: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j x11-terms/terminator
	make fonts

chromium: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j www-client/chromium

adobe-flash: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.license/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j www-plugins/adobe-flash

# -- Python
python: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j dev-lang/python
	eselect python set python2.7
ifneq ($(shell eselect python list | grep python | wc -l), 1)
	#python-updater -- -q -j --with-bdeps y --keep-going
	python-updater \
		-dmanual -dpylibdir -dPYTHON_ABIS -dshared_linking -dstatic_linking \
		-- -q -j --with-bdeps y --keep-going
#ifeq (${NO_ASK},)
	#${EMERGE} --depclean -av -j
	#revdep-rebuild -v -- --ask -j
#else
	${EMERGE} -q --depclean -j
	revdep-rebuild -q -- -j
#endif
	#eselect python list | grep 'python2.7 *' || ( \
		#eselect python set python2.7 \
		#&& python-updater -- -q -j --with-bdeps y --keep-going \
		#&& ${EMERGE} --depclean -av -q -j \
		#&& revdep-rebuild -v -- --ask -q -j \
		#)
endif

pip: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/pip
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/pip
	${EMERGE} -uN -q -j dev-python/pip

setuptools: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/setuptools
	${EMERGE} -uN -q -j dev-python/setuptools

virtualenv: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/virtualenv
	${EMERGE} -uN -q -j dev-python/virtualenv

virtualenvwrapper: portage-dirs virtualenv overlay-sekyfsr
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/virtualenvwrapper
	USE_PYTHON='2.7' ${EMERGE} -uN -q -j dev-python/virtualenvwrapper

ipython: portage-dirs pyqt4
	cp -f {files,${EPREFIX}}/etc/portage/package.use/ipython
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/ipython
	${EMERGE} -uN -q -j dev-python/ipython

ipdb: portage-dirs ipython
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/ipdb
	${EMERGE} -uN -q -j dev-python/ipdb

cython: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j dev-python/cython

pep8: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/pep8
	${EMERGE} -uN -q -j dev-python/pep8

autopep8: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/autopep8
	${EMERGE} -uN -q -j dev-python/autopep8

numpy: portage-dirs atlas
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j dev-python/numpy

scipy: portage-dirs numpy atlas
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j sci-libs/scipy

matplotlib: portage-dirs scipy
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j dev-python/matplotlib

numexpr: portage-dirs mkl
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/numexpr
	cp -f {files,${EPREFIX}}/etc/portage/package.use/numexpr
	${EMERGE} -uN -q -j --onlydeps dev-python/numexpr
	FEATURES=test ${EMERGE} -uN dev-python/numexpr

joblib: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j dev-python/joblib

scikits.learn: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j sci-libs/scikits_learn

scikits.image: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j dev-python/pyfits
	${EMERGE} -uN -q -j sci-libs/scikits_image

Theano: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j sci-libs/Theano

pytables: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/pytables
	${EMERGE} -uN -q -j dev-python/pytables

pymongo: portage-dirs mongodb
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/pymongo
	${EMERGE} -uN -q -j dev-python/pymongo

pyqt4: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j dev-python/PyQt4

pycuda: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j dev-python/pycuda

pyopencl: portage-dirs opencl
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j dev-python/pyopencl

simplejson: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j dev-python/simplejson

fabric: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j dev-python/fabric

cgkit: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j dev-python/cgkit

# -- Scientific Libraries
atlas: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.mask/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.unmask/$@
	${EMERGE} -uN -q -j sys-power/cpufrequtils
	cpufreq-set -g performance || true
	${EMERGE} -uN sci-libs/blas-atlas sci-libs/lapack-atlas
	eselect blas list | grep 'atlas-threads \*' || eselect blas set atlas-threads
	eselect cblas list | grep 'atlas-threads \*' || eselect cblas set atlas-threads
	eselect lapack list | grep 'atlas \*' || eselect lapack set atlas

icc: portage-dirs overlay-sekyfsr
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/icc
	cp -f {files,${EPREFIX}}/etc/portage/package.use/icc
	cp -f {files,${EPREFIX}}/etc/portage/package.license/icc
	${EMERGE} -uN dev-lang/icc

tbb: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/tbb
	${EMERGE} -uN -q -j dev-cpp/tbb

mkl: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/mkl
	cp -f {files,${EPREFIX}}/etc/portage/package.license/mkl
	${EMERGE} -uN -q -j sci-libs/mkl

shogun: portage-dirs layman overlay-sekyfsr
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j sci-libs/shogun

boost:
	cp -f {files,${EPREFIX}}/etc/portage/package.mask/$@
	${EMERGE} -uN -q -j dev-libs/boost dev-util/boost-build

hdf5:
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j sci-libs/hdf5

# -- Database
mongodb: portage-dirs boost
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j dev-db/mongodb

# -- Image / Video
jpeg:
	${EMERGE} --deselect media-libs/jpeg
	${EMERGE} -uN -q -j media-libs/libjpeg-turbo

opencv: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.license/$@
	${EMERGE} -uN -q -j media-libs/opencv

freeimage: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j media-libs/freeimage

imagemagick: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j media-gfx/imagemagick

mplayer: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j media-video/mplayer

# -- Misc
fonts:
	${EMERGE} -uN -q -j $(shell eix --only-names -A media-fonts -s font-)
	# from "Using UTF-8 with Gentoo" (http://www.gentoo.org/doc/en/utf-8.xml)
	${EMERGE} -uN -q -j terminus-font intlfonts freefonts corefonts
	# DejaVu fonts
	${EMERGE} -uN -q -j media-fonts/dejavu
	eselect fontconfig list | grep dejavu
	fc-match | grep DejaVuSans || exit 1
	fc-match "Monospace" | grep DejaVuSansMono || exit 1

dropbox: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j net-misc/dropbox
	sysctl -w fs.inotify.max_user_watches=1000000
	grep max_user_watches /etc/sysctl.conf || \
		echo "fs.inotify.max_user_watches = 1000000" >>  /etc/sysctl.conf
	sed -i 's/fs\.inotify\.max_user_watches.*/fs\.inotify\.max_user_watches = 1000000/g' /etc/sysctl.conf

texlive: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j app-text/texlive
	#${EMERGE} -uN -q -j app-text/texlive-core

cairo: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j x11-libs/cairo

ntfs3g: portage-dirs
	CLEAN_DELAY=0 ${EMERGE} -q -C sys-fs/ntfsprogs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j sys-fs/ntfs3g

valgrind: portage-dirs
	grep -e '^FEATURES.*=.*splitdebug' /etc/make.conf \
		|| echo 'FEATURES="$${FEATURES} splitdebug"' >> /etc/make.conf
ifeq ($(shell if test -d /usr/lib/debug/usr/lib64/misc/glibc; then echo true; else echo false; fi), false)
	${EMERGE} -q sys-libs/glibc
endif
	${EMERGE} -uN -q -j dev-util/valgrind

megacli: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	${EMERGE} -uN -q -j sys-block/megacli

# -- X
xorg-server: portage-dirs
	${EMERGE} -uN -q -j x11-base/xorg-server

nvidia-drivers: portage-dirs gcc xorg-server
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j x11-drivers/nvidia-drivers
	eselect opengl set nvidia
	${EMERGE} -uN -q -j app-admin/eselect-opencl
	eselect opencl set nvidia

nvidia-settings: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	${EMERGE} -uN -q -j media-video/nvidia-settings

# -- OpenCL
opencl: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.license/$@
	${EMERGE} -uN -q -j virtual/opencl

# -- CUDA
cuda: portage-dirs layman nvidia-drivers nvidia-settings overlay-sekyfsr
	eix-sync -q
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/cuda
	cp -f {files,${EPREFIX}}/etc/portage/package.use/cuda
	${EMERGE} -uN -q -j '=dev-util/nvidia-cuda-toolkit-4.2'
	${EMERGE} -uN -q -j '=dev-util/nvidia-cuda-sdk-4.2'
	${EMERGE} -uN -q -j dev-util/nvidia-cuda-tdk
	make module-rebuild

# -- Java
${EPREFIX}/usr/portage/distfiles/jdk-6u31-linux-x64.bin:
	wget http://dl.dropbox.com/u/167753/fuck-oracle/jdk-6u31-linux-x64.bin
	mv -vf jdk-6u31-linux-x64.bin $@

sun-jdk: ${EPREFIX}/usr/portage/distfiles/jdk-6u31-linux-x64.bin
	cp -f {files,${EPREFIX}}/etc/portage/package.license/$@
	${EMERGE} -uN -q -j dev-java/sun-jdk
