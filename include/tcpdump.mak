NAME := tcpdump
TCPDUMP_VERSION := 4.99.1
TCPDUMP_URL := https://www.tcpdump.org/release/tcpdump-$(TCPDUMP_VERSION).tar.gz
TCPDUMP_PROGRAMS := tcpdump
TCPDUMP_LIBRARIES :=

# Adding OpenSSL's crypto library adds around 2MB.
TCPDUMP_CONFIG = --without-crypto

$(eval $(call create_recipes, \
	$(NAME), \
	$(TCPDUMP_VERSION), \
	$(TCPDUMP_URL), \
	$(TCPDUMP_PROGRAMS), \
	$(TCPDUMP_LIBRARIES), \
))

# NOTE: tcpdump can include the build machine's include directories
# if it detects pcap headers on your system.  This can be disabled
# by overridden by resetting the INCLS variable to the default value.
$(BUILD_FLAG): $$(libpcap)
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  $(TCPDUMP_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)" INCLS="-I."
	$(MAKE) -C "$(SRC)" install

ALL_PROGRAMS += $(TCPDUMP_PROGRAMS)