NAME := socat
SOCAT_VERSION := 1.7.4.3
SOCAT_URL := http://www.dest-unreach.org/socat/download/socat-$(SOCAT_VERSION).tar.gz
SOCAT_PROGRAMS := socat procan filan
SOCAT_LIBRARIES :=
# NOTE: yes, that's an insecure HTTP download URL.
# The HTTPS version provides a certificate for the wrong domain,
# so we'd have to turn off certificate verification anyways.
# There's also a git repo, but it's hosted on a different 3rd domain.

# Enabling OpenSSL makes socat 10x larger.
SOCAT_CONFIG = --disable-openssl --disable-readline

$(eval $(call create_recipes, \
	$(NAME), \
	$(SOCAT_VERSION), \
	$(SOCAT_URL), \
	$(SOCAT_PROGRAMS), \
	$(SOCAT_LIBRARIES), \
))

# NOTE: without `-Werror-implicit-function-declaration` during configure,
# configure incorrectly detects that getprotobynumber_r is available
# even though the compilation threw an "implicit declaration" warning.
$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  $(SOCAT_CONFIG) \
	  CFLAGS="$(CFLAGS) -Werror-implicit-function-declaration" \
	  LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)"
	$(MAKE) -C "$(SRC)" install

# If not explicitly disabled, socat prefers having OpenSSL.
ifeq (,$(findstring disable-openssl,$(SOCAT_CONFIG)))
$(BUILD_FLAG): $$(libssl) $$(libcrypto)
endif

# If not explicitly disabled, socat prefers having readline.
ifeq (,$(findstring disable-readline,$(SOCAT_CONFIG)))
$(BUILD_FLAG): $$(libreadline)
endif

ALL_PROGRAMS += $(SOCAT_PROGRAMS)
DEFAULT_PROGRAMS += socat