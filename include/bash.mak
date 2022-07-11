NAME := bash
BASH_VERSION := 5.1.16
BASH_URL := https://ftp.gnu.org/gnu/bash/bash-$(BASH_VERSION).tar.gz
BASH_PROGRAMS := bash
BASH_LIBRARIES :=

BASH_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(BASH_VERSION), \
	$(BASH_URL), \
	$(BASH_PROGRAMS), \
	$(BASH_LIBRARIES), \
))

$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --enable-static-link \
	  $(BASH_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)"
	$(MAKE) -C "$(SRC)" install

ALL_PROGRAMS += $(BASH_PROGRAMS)
DEFAULT_PROGRAMS += $(BASH_PROGRAMS)