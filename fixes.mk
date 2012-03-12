all: libpng14-news pambase-freeze v8-revdep-rebuild

libpng14-news:
	revdep-rebuild -q --library libpng14.so.14 -- --keep-going
	revdep-rebuild -q --library libpng14.so.14 -- --keep-going
	find /usr/ -name '*.la' -exec grep png14 {} + || exit 0
	rm -vf '/usr/lib64/libpng14.so.14'

pambase-freeze:
	emerge -q '=app-portage/portage-utils-0.3.1'
	emerge -q sys-auth/pambase
	emerge -q app-portage/portage-utils

v8-revdep-rebuild:
	revdep-rebuild -q --library '/usr/lib64/libv8-3.6.6.11.so'
	rm -vf '/usr/lib64/libv8-3.6.6.11.so'
