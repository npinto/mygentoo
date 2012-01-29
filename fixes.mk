all: libpng14-news pambase-freeze

libpng14-news:
	revdep-rebuild --library libpng14.so.14 -- --keep-going
	revdep-rebuild --library libpng14.so.14 -- --keep-going
	find /usr/ -name '*.la' -exec grep png14 {} + || exit 0

pambase-freeze:
	emerge '=app-portage/portage-utils-0.3.1'
	emerge sys-auth/pambase
	emerge app-portage/portage-utils
