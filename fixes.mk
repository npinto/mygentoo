all: libpng14-news pambase-freeze v8-revdep-rebuild

libpng14-news:
	revdep-rebuild --library libpng14.so.14 -- --keep-going -q
	revdep-rebuild --library libpng14.so.14 -- --keep-going -q
	find /usr/ -name '*.la' -exec grep png14 {} + || exit 0
	rm -vf '/usr/lib64/libpng14.so.14'

pambase-freeze:
	emerge '=app-portage/portage-utils-0.3.1'
	emerge sys-auth/pambase
	emerge app-portage/portage-utils

v8-revdep-rebuild:
	revdep-rebuild --library '/usr/lib64/libv8-3.6.6.11.so' -q
	rm -vf '/usr/lib64/libv8-3.6.6.11.so'
