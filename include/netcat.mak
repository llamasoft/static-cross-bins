NAME := netcat
NETCAT_VERSION := 0.7.1
NETCAT_URL := https://downloads.sourceforge.net/project/netcat/netcat/$(NETCAT_VERSION)/netcat-$(NETCAT_VERSION).tar.gz
NETCAT_PROGRAMS := netcat
NETCAT_LIBRARIES :=

NETCAT_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(NETCAT_VERSION), \
	$(NETCAT_URL), \
	$(NETCAT_PROGRAMS), \
	$(NETCAT_LIBRARIES), \
))

# NOTE: this is the "original" netcat, not the BSD version.
# The bundled configure script is so out of date that it's
# never heard of musl and thinks it's invalid.
# Because of this, forcing autoreconf to run is mandatory.
$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && autoreconf -if
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  $(NETCAT_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)"
	$(MAKE) -C "$(SRC)" install-exec

ALL_PROGRAMS += $(NETCAT_PROGRAMS)
DEFAULT_PROGRAMS += $(NETCAT_PROGRAMS)