include init.mk


me:
ifeq ($(strip ${EPREFIX}), )
	make _$(shell hostname | sed "s;[0-9]*;;g")
else
	make _prefix
endif

_desktop:
	make awesome
	make chromium
	make adobe-flash
	make gnome-terminal

_dev:
	make portage-sqlite
	#make autounmask
	make atlas
	make autopep8
	#make bind
	make cairo
	#make cgkit
	make cuda
	make cython
	#make dropbox
	make eix
	make evince
	make fabric
	make feh
	make fonts
	make freeimage
	make gcc
	make gdm
	make gthumb
	make gvim
	make icc
	make jpeg
	make imagemagick
	make ipdb
	make ipython
	make joblib
	make layman
	make locale
	make matplotlib
	make mkl
	make module-rebuild
	make mongodb
	make mplayer
	make nautilus
	make ntfs3g
	make numexpr
	make numpy
	make nvidia-drivers
	make nvidia-settings
	make opencl
	make parallel
	make pep8
	make pip
	make pycuda
	make pymongo
	make pyopencl
	make pyqt4
	make pytables
	make python
	make scikits.image
	make scikits.learn
	make scipy
	make setuptools
	make shogun
	make simplejson
	make sun-jdk
	make tbb
	make terminator
	make texlive
	make Theano
	make valgrind
	make vim
	make virtualenv
	make virtualenvwrapper
	make wgetpaste
	make xdg
	make xdg-config
	#make opencv
	# --
	make zsh
	make ncdu
	make htop
	make tmux

_primo: _dev _desktop
_logilo: _dev _desktop
_thor-dev-: _dev _desktop
_munctional: _dev
_kraken: _dev
_squid: _dev
_ip----: _ec2

_honeybadger:
	make portage-sqlite
	make eix
	make locale
	make layman
	make gcc
	make fabric
	make parallel
	# --
	make vim
	# --
	make python
	make setuptools
	make pip
	make ipython ipdb
	make virtualenv virtualenvwrapper
	# --
	make atlas
	make numpy scipy
	make matplotlib
	make cython
	make pep8 autopep8
	make joblib
	make cairo
	make cgkit
	make numexpr
	make scikits.image
	make scikits.learn
	make Theano
	make simplejson
	# --
	make nvidia-drivers
	make nvidia-settings
	make cuda
	make pycuda
	make opencl
	make pyopencl
	# --
	make pyqt4
	make pytables
	# --
	make mkl
	make icc
	make valgrind
	make tbb
	make shogun
	# --
	make jpeg
	make freeimage
	make imagemagick
	make gthumb
	make mplayer
	#make opencv
	# --
	make mongodb
	make pymongo
	# --
	make texlive
	make wgetpaste
	# --
	make megacli
	${EMERGE} -uN -j sys-process/htop
	${EMERGE} -uN -j app-misc/tmux

_prefix:
	make portage-sqlite
	make eix
	#make locale
	make layman
	#make gcc
	make fabric
	make parallel
	# --
	make vim
	# --
	make python
	make setuptools
	make pip
	make ipython ipdb
	make virtualenv virtualenvwrapper
	# --
	make atlas
	make numpy scipy
	#make matplotlib
	make cython
	make pep8 autopep8
	make joblib
	make cairo
	#make cgkit
	#make numexpr
	make scikits.image
	make scikits.learn
	make Theano
	make simplejson
	# --
	#make nvidia-drivers
	#make nvidia-settings
	#make cuda
	#make pycuda
	#make opencl
	#make pyopencl
	# --
	make pyqt4
	make pytables
	# --
	#make mkl
	#make icc
	#make valgrind
	#make tbb
	#make shogun
	# --
	make jpeg
	#make freeimage
	make imagemagick
	#make gthumb
	#make mplayer
	#make opencv
	# --
	#make mongodb
	make pymongo
	# --
	#make texlive
	make wgetpaste
	# --
	#make megacli
	#make sun-jdk
	#make tbb
	#make terminator
	#make texlive
	#make valgrind
	#make vim
	#make wgetpaste
	#make xdg
	#make xdg-config
	#make opencv
	# --
	make zsh
	make ncdu
	make htop
	make tmux

_ec2:
	make portage-sqlite
	make atlas
	make autopep8
	make cairo
	make cuda
	make cython
	make eix
	make fabric
	make feh
	make freeimage
	make gcc
	make gthumb
	make icc
	make jpeg
	make imagemagick
	make ipdb
	make ipython
	make joblib
	make layman
	make locale
	make matplotlib
	#make mkl
	make module-rebuild
	make mongodb
	make mplayer
	make nautilus
	make numexpr
	make numpy
	make nvidia-drivers
	make nvidia-settings
	make opencl
	make parallel
	make pep8
	make pip
	make pycuda
	make pymongo
	make pyopencl
	make pyqt4
	make pytables
	make python
	make scikits.image
	make scikits.learn
	make scipy
	make setuptools
	make shogun
	make simplejson
	make sun-jdk
	make tbb
	make terminator
	#make texlive
	make Theano
	make valgrind
	make vim
	make virtualenv
	make virtualenvwrapper
	make wgetpaste
	# --
	make zsh
	make ncdu
	make htop
	make tmux
