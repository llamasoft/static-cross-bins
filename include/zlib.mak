NAME := zlib
ZLIB_VERSION := 1.2.13
ZLIB_URL := https://github.com/madler/zlib/archive/refs/tags/v$(ZLIB_VERSION).tar.gz
ZLIB_PROGRAMS :=
ZLIB_LIBRARIEES := libz.a

$(eval $(call create_recipes, \
	$(NAME), \
	$(ZLIB_VERSION), \
	$(ZLIB_URL), \
	$(ZLIB_PROGRAMS), \
	$(ZLIB_LIBRARIEES), \
))

# NOTE: zlib's configure script isn't from autotools.
# It doesn't support --host or passing build flags.
# Instead, we'll pass build flags directly to the build step.
$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  --prefix="$(SYSROOT)" --static
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" install
