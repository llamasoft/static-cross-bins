ifeq (libressl,$(OPENSSL))

NAME := libressl
LIBRESSL_VERSION := 3.5.3
LIBRESSL_URL := https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$(LIBRESSL_VERSION).tar.gz
LIBRESSL_PROGRAMS := openssl
LIBRESSL_LIBRARIES := libssl.a libcrypto.a libtls.a

LIBRESSL_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(LIBRESSL_VERSION), \
	$(LIBRESSL_URL), \
	$(LIBRESSL_PROGRAMS), \
	$(LIBRESSL_LIBRARIES), \
))

# This package uses libtool and needs LDFLAGS to include -all-static
# in order to produce a statically linked binary.  However, the
# configure script doesn't use libtool, so the flag must be injected
# at built-time only, otherwise the configure will fail.
#   See https://stackoverflow.com/a/54168321/477563
$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --disable-shared --enable-static \
	  --disable-tests --disable-asm \
	  $(LIBRESSL_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)" LDFLAGS="$(LDFLAGS) -all-static"
	$(MAKE) -C "$(SRC)" install-exec

ALL_PROGRAMS += $(LIBRESSL_PROGRAMS)

endif