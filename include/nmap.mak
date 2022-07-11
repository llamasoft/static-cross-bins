NAME := nmap
NMAP_VERSION := 7.92
NMAP_URL := https://nmap.org/dist/nmap-$(NMAP_VERSION).tgz
NMAP_PROGRAMS := nmap nping ncat
NMAP_LIBRARIES :=

# Enabling OpenSSL adds around 2.5MB.
NMAP_CONFIG = --without-openssl

$(eval $(call create_recipes, \
	$(NAME), \
	$(NMAP_VERSION), \
	$(NMAP_URL), \
	$(NMAP_PROGRAMS), \
	$(NMAP_LIBRARIES), \
))

# NOTE: a lot of the libraries included with nmap will attempt to use the
# system's AR and RANLIB unless specifically overridden.  Normally make's -e
# flag would fix this but it isn't passed to recursive calls to other makefiles.
# To make matters frustrating:
# - liblua doesn't use ARFLAGS and instead embeds them in AR.
# - libnetutil doesn't use ARFLAGS and instead embeds them in the make recipe.
# - libz actually uses AR=libtool with corresponding ARFLAGS.
# The net result is that at least one library has to be built manually.
# BONUS: because the nmap binary depends on phony targets, the binary is always
# rebuilt, even when calling the  install target.  To prevent having to pass
# STATIC to multiple make calls, we'll go directly to calling the install target.
# This is easily one of the work makefiles I've ever had to deal with.
# BONUS BONUS: even though nmap comes with libz, we have to use our own copy
# because on most systems libz will attempt to build a static and a shared library.
# However, nmap passes the static build flags to both, causing it to fail.
$(BUILD_FLAG): $$(libpcap) $$(libz)
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --without-zenmap --without-nmap-update --without-ndiff \
	  --with-libpcap="$(SYSROOT)" \
	  --with-libz="$(SYSROOT)" \
	  --with-libpcre=included \
	  --with-libssh2=included \
	  --with-liblua=included \
	  $(NMAP_CONFIG) \
	  CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)" build-lua \
	  AR="$(AR) cr" RANLIB="$(RANLIB)"
	$(MAKE) -C "$(SRC)" install \
	  AR="$(AR)" ARFLAGS="cr" RANLIB="$(RANLIB)" STATIC="-static"

# The libdnet included with nmap configures settings based on the build
# machine, not the machine we're cross-compiling for.  As a result, some flags
# (e.g. procfs, Berkeley Packet Filter) may end up with incorrect values.
# For compatibility, we'll override some of the configure script's internal
# variables to ensure we use the generic Linux ethernet driver.

# Berkeley Packet Filter determined based on presence of /dev/bpf0.
# The musl toolchain doesn't have <net/bpf.h> so this must be disabled.
$(BUILD_FLAG): export ac_cv_dnet_bsd_bpf=no

# Determined based on contents of /proc/sys/kernel/ostype, if present.
# This should be present on all non-antique versions of Linux.
$(BUILD_FLAG): export ac_cv_dnet_linux_procfs=yes

# The musl toolchain has these headers even if the build system doesn't.
$(BUILD_FLAG): export ac_cv_dnet_linux_pf_packet=yes
$(BUILD_FLAG): export ac_cv_header_linux_if_tun_h=yes

# If not explicitly disabled, nmap prefers having OpenSSL.
# Due to a quirk in the included libssh2 library, if we supply our own OpenSSL
# library then we also have to supply our own libz because libssh2 expects libz
# to already be compiled even though nmap hasn't built it yet.
ifeq (,$(findstring without-openssl,$(NMAP_CONFIG)))
$(BUILD_FLAG): $$(libssl) $$(libcrypto)
override NMAP_CONFIG := $(filter-out --with%openssl%,$(NMAP_CONFIG))
override NMAP_CONFIG := $(NMAP_CONFIG) --with-openssl="$(SYSROOT)"
endif

ALL_PROGRAMS += $(NMAP_PROGRAMS)