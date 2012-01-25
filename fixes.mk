all: libpng14

libpng14:
	revdep-rebuild --library libpng14.so.14 -- --keep-going
	revdep-rebuild --library libpng14.so.14 -- --keep-going
	find /usr/ -name '*.la' -exec grep png14 {} + || exit 0
