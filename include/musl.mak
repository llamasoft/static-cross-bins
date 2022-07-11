# musl-cross-make hasn't had an official release since 2020 but has had many
# updates and bigfixes since then.  Instead, we'll download a commit directly.
NAME := musl-cross-make
MUSL_VERSION := fe91582
MUSL_URL := https://github.com/richfelker/musl-cross-make/tarball/$(MUSL_VERSION)
MUSL_SRC := $(SOURCE_ROOT)/$(NAME)-$(MUSL_VERSION)
MUSL := $(SYSROOT)/bin/$(TARGET)-cc

MUSL_CONFIG =

# NOTE: we can't use create_recipes otherwise musl will depend on itself.

.PHONY: musl
musl: | $(MUSL)

$(MUSL): | $(MUSL_SRC)
	$(eval $(call activate_paths,$@))
# Remove tar verbose flag as it results in over 120k lines of output.
	sed -i".bak" "s/xvf/xf/" "$(MUSL_SRC)/Makefile"
	$(MAKE) -C "$(MUSL_SRC)" \
	  TARGET="$(TARGET)" \
	  COMMON_CONFIG='CFLAGS="-g0 -Os" CXXFLAGS="-g0 -Os" LDFLAGS="-s"' \
	  DL_CMD="$(DOWNLOAD)" \
	  $(MUSL_CONFIG)
	$(MAKE) -C "$(MUSL_SRC)" install \
	  TARGET="$(TARGET)" \
	  OUTPUT="$(SYSROOT)"

$(MUSL_SRC):
	$(call untar_to_dir,$(MUSL_URL),$@)