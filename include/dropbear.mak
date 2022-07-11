NAME := dropbear
DROPBEAR_VERSION := 2022.82
DROPBEAR_URL := https://github.com/mkj/dropbear/archive/refs/tags/DROPBEAR_$(DROPBEAR_VERSION).tar.gz
DROPBEAR_PROGRAMS := dropbear dbclient dropbearkey dropbearconvert scp
DROPBEAR_LIBRARIES :=

DROPBEAR_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(DROPBEAR_VERSION), \
	$(DROPBEAR_URL), \
	$(DROPBEAR_PROGRAMS), \
	$(DROPBEAR_LIBRARIES), \
))

$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --sbindir="$(SYSROOT)/bin" --enable-static \
	  $(DROPBEAR_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)" PROGRAMS="$(DROPBEAR_PROGRAMS)"
	$(MAKE) -C "$(SRC)" install PROGRAMS="$(DROPBEAR_PROGRAMS)"

# If not explicitly disabled, dropbear needs zlib.
ifeq (,$(findstring disable-zlib,$(DROPBEAR_CONFIG)))
$(BUILD_FLAG): $$(libz)
endif

ALL_PROGRAMS += $(DROPBEAR_PROGRAMS)