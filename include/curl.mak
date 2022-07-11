NAME := curl
CURL_VERSION := 7.83.1
CURL_URL := https://github.com/curl/curl/releases/download/curl-$(subst .,_,$(CURL_VERSION))/curl-$(CURL_VERSION).tar.gz
CURL_PROGRAMS := curl
CURL_LIBRARIES := libcurl.a

CURL_CONFIG =

# WolfSSL results in a much smaller binary (around 1MB).
# The only reason you'd use OpenSSL here is if you already
# need the library for other things and don't care about size.
CURL_SSL := wolfssl
# CURL_SSL := openssl

$(eval $(call create_recipes, \
	$(NAME), \
	$(CURL_VERSION), \
	$(CURL_URL), \
	$(CURL_PROGRAMS), \
	$(CURL_LIBRARIES), \
))

# This package uses libtool and needs LDFLAGS to include -all-static
# in order to produce a statically linked binary.  However, the
# configure script doesn't use libtool, so the flag must be injected
# at built-time only, otherwise the configure will fail.
#   See https://stackoverflow.com/a/54168321/477563
$(BUILD_FLAG): $$(libz)
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --disable-shared --enable-static --with-$(CURL_SSL) \
	  $(CURL_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(filter -L%,$(LDFLAGS))"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)" LDFLAGS="$(LDFLAGS) -all-static"
	$(MAKE) -C "$(SRC)" install-exec

# Update dependencies based on chosen SSL library.
ifeq ($(CURL_SSL),wolfssl)
$(BUILD_FLAG): $$(libwolfssl)
else ifeq ($(CURL_SSL),openssl)
$(BUILD_FLAG): $$(libssl)
else
$(error Invalid CURL_SSL selection: $(CURL_SSL))
endif

ALL_PROGRAMS += $(CURL_PROGRAMS)
DEFAULT_PROGRAMS += $(CURL_PROGRAMS)