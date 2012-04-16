default: help

help:
	make list

list:
	@#@echo Available targets:
	@#@echo ------------------
	@./make-list-targets.sh -f Makefile | grep -v '_.*' | cut -d':' -f1

all:
	make $(shell make list | grep -v all)

update:
	(test ${NO_EIX_SYNC} || \
		eix-sync -q \
		) || true
	glsa-check -q -t all
	glsa-check -q -f all
	emerge -tavuDN -j --with-bdeps y --keep-going world system
	emerge -tav --depclean
	revdep-rebuild -v -- --ask
	eclean-dist -d
	eix-test-obsolete
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

portage-sqlite: portage-dirs
	# -- portage sql cache
	# See:
	#  http://en.gentoo-wiki.com/wiki/Portage_SQLite_Cache
	#  http://www.gentoo-wiki.info/TIP_speed_up_portage_with_sqlite
	#  http://forums.gentoo.org/viewtopic.php?t=261580
	grep -e '^FEATURES.*=.*metadata-transfer' /etc/make.conf \
		|| ( \
		emerge -uN -j dev-python/pysqlite \
		&& cp -f {files,${EPREFIX}}/etc/portage/modules \
		&& echo 'FEATURES="$${FEATURES} metadata-transfer"' >> /etc/make.conf \
		&& rm -rf /var/cache/edb/dep \
		&& emerge --metadata \
		&& make eix \
		)

eix: portage-dirs layman
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j app-portage/eix
	cp -f {files,${EPREFIX}}/etc/eix-sync.conf
	cp -f {files,${EPREFIX}}/etc/eixrc
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
	layman -q -s ${OVERLAY}
	egencache --repo='sekyfsr' --update

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
		&& emerge -uN -q '=sys-devel/gcc-4.5.3-r2' \
		&& gcc-config x86_64-pc-linux-gnu-4.5.3 \
		&& gcc-config -l \
		&& emerge --oneshot -q libtool)
	# -- gcc-4.6
	emerge -uN -q '=sys-devel/gcc-4.6.2'
	# -- gcc-4.1
	#emerge -uN -q '=sys-devel/gcc-4.1.2'

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

feh: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j media-gfx/feh

awesome: portage-dirs feh
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	cp -f {files,${EPREFIX}}/usr/share/xsessions/awesome.desktop
	emerge -uN -j x11-wm/awesome
	make fonts

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
	make fonts

terminator: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j x11-terms/terminator
	make fonts

chromium: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j www-client/chromium

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

virtualenvwrapper: portage-dirs virtualenv overlay-sekyfsr
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

numpy: portage-dirs atlas
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-python/numpy

scipy: portage-dirs numpy atlas
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j sci-libs/scipy

matplotlib: portage-dirs scipy
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j dev-python/matplotlib

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

# -- Scientific Libraries
atlas: portage-dirs
	emerge -uN sys-power/cpufrequtils
	cpufreq-set -g performance
	emerge -uN sci-libs/blas-atlas sci-libs/lapack-atlas
	eselect blas list | grep 'atlas-threads \*' || eselect blas set atlas-threads
	eselect cblas list | grep 'atlas-threads \*' || eselect cblas set atlas-threads
	eselect lapack list | grep 'atlas \*' || eselect lapack set atlas

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

shogun: portage-dirs layman overlay-sekyfsr
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/shogun
	cp -f {files,${EPREFIX}}/etc/portage/package.use/shogun
	emerge -uN -j sci-libs/shogun

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
fonts:
	emerge -uN -j $(shell eix --only-names -s font-)
	# from "Using UTF-8 with Gentoo" (http://www.gentoo.org/doc/en/utf-8.xml)
	emerge -uN -j terminus-font intlfonts freefonts corefonts
	# DejaVu fonts
	emerge -uN -j media-fonts/dejavu
	eselect fontconfig list | grep dejavu
	fc-match | grep DejaVuSans || exit 1
	fc-match "Monospace" | grep DejaVuSansMono || exit 1

dropbox: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j net-misc/dropbox
	sysctl -w fs.inotify.max_user_watches=1000000
	grep max_user_watches /etc/sysctl.conf || \
		echo "fs.inotify.max_user_watches = 1000000" >>  /etc/sysctl.conf
	sed -i 's/fs\.inotify\.max_user_watches.*/fs\.inotify\.max_user_watches = 1000000/g' /etc/sysctl.conf

texlive: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j app-text/texlive
	#emerge -uN -j app-text/texlive-core

cairo: portage-dirs
	cp -f {files,${EPREFIX}}/etc/portage/package.keywords/$@
	emerge -uN -j x11-libs/cairo

ntfs3g: portage-dirs
	CLEAN_DELAY=0 emerge -q -C sys-fs/ntfsprogs
	cp -f {files,${EPREFIX}}/etc/portage/package.use/$@
	emerge -uN -j sys-fs/ntfs3g

valgrind: portage-dirs
	grep -e '^FEATURES.*=.*splitdebug' /etc/make.conf \
		|| echo 'FEATURES="$${FEATURES} splitdebug"' >> /etc/make.conf
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

cuda: portage-dirs layman nvidia-drivers nvidia-settings overlay-sekyfsr
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

