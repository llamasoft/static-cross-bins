NAME := busybox
BUSYBOX_VERSION := 1.35.0
BUSYBOX_URL := https://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_PROGRAMS := busybox
BUSYBOX_LIBRARIES :=

BUSYBOX_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(BUSYBOX_VERSION), \
	$(BUSYBOX_URL), \
	$(BUSYBOX_PROGRAMS), \
	$(BUSYBOX_LIBRARIES), \
))

# The CONFIG_ options need to be passed to almost every make
# invocation unless we modify the config files directly.
BUSYBOX_DEFAULTS := CONFIG_PREFIX="$(SYSROOT)" CONFIG_STATIC="y"
BUSYBOX_DEFAULTS += CONFIG_INSTALL_APPLET_DONT="y"
BUSYBOX_DEFAULTS += CONFIG_INSTALL_APPLET_SYMLINKS="n"

# NOTE: the busybox makefile doesn't respect our exported toolchain
# variables (CC, LD, etc) so the build must use make's -e flag to
# force our environment variables to take precedence.
$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)" defconfig
	$(MAKE) -C "$(SRC)" -e \
	  $(BUSYBOX_DEFAULTS) \
	  $(BUSYBOX_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" -e install \
	  $(BUSYBOX_DEFAULTS) \
	  $(BUSYBOX_CONFIG)

ALL_PROGRAMS += $(BUSYBOX_PROGRAMS)
DEFAULT_PROGRAMS += $(BUSYBOX_PROGRAMS)