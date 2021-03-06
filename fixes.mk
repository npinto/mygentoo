all: libpng14-news pambase-freeze v8-revdep-rebuild \
	glsa-201203-12

libpng14-news:
	revdep-rebuild -q --library libpng14.so.14 -- --keep-going
	find /usr/ -name '*.la' -exec grep png14 {} + || exit 0
	rm -vf '/usr/lib64/libpng14.so.14'

pambase-freeze:
	emerge -q '=app-portage/portage-utils-0.3.1'
	emerge -q sys-auth/pambase
	emerge -q app-portage/portage-utils

v8-revdep-rebuild:
	revdep-rebuild -q --library '/usr/lib64/libv8-3.6.6.11.so'
	rm -f '/usr/lib64/libv8-3.6.6.11.so'
	revdep-rebuild -q --library '/usr/lib64/libv8.so.3.7.12.20'
	rm -f '/usr/lib64/libv8.so.3.7.12.20'
	revdep-rebuild -q --library '/usr/lib64/libv8.so.3.7.12.29'
	rm -f '/usr/lib64/libv8.so.3.7.12.29'
	revdep-rebuild -q --library '/usr/lib64/libv8.so.3.8.9'
	rm -f '/usr/lib64/libv8.so.3.8.9'

glsa-201203-12:
	emerge --sync --quiet
	emerge -uN --quiet --oneshot ">=dev-libs/openssl-1.0.0g"
	-CLEAN_DELAY=0 emerge -q -C '<dev-libs/openssl-1.0.0g'

 #emerge portage-utils; qlist -I -C x11-drivers/

