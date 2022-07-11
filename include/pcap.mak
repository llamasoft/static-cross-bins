NAME := pcap
PCAP_VERSION := 1.10.1
PCAP_URL := https://www.tcpdump.org/release/libpcap-$(PCAP_VERSION).tar.gz
PCAP_PROGRAMS :=
PCAP_LIBRARIES := libpcap.a

PCAP_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(PCAP_VERSION), \
	$(PCAP_URL), \
	$(PCAP_PROGRAMS), \
	$(PCAP_LIBRARIES), \
))

$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --disable-shared \
	  $(PCAP_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)"
	$(MAKE) -C "$(SRC)" install