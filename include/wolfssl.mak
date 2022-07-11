NAME := wolfssl
WOLFSSL_VERSION := 5.3.0
WOLFSSL_URL := https://github.com/wolfSSL/wolfssl/archive/refs/tags/v$(WOLFSSL_VERSION)-stable.tar.gz
WOLFSSL_PROGRAMS :=
WOLFSSL_LIBRARIES := libwolfssl.a

$(eval $(call create_recipes, \
	$(NAME), \
	$(WOLFSSL_VERSION), \
	$(WOLFSSL_URL), \
	$(WOLFSSL_PROGRAMS), \
	$(WOLFSSL_LIBRARIES), \
))

$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && autoreconf -i
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --disable-shared --enable-static \
	  --enable-opensslall \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)"
	$(MAKE) -C "$(SRC)" install