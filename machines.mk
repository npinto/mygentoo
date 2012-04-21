
me:
	make _$(shell hostname)

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
	make numpy scipy matplotlib
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
	make freeimage
	make imagemagick
	make gthumb
	make mplayer
	# --
	make mongodb
	make pymongo
	# --
	make texlive
	make wgetpaste
	# --
	make megacli
