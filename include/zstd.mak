NAME := zstd
ZSTD_VERSION := 1.5.2
ZSTD_URL := https://github.com/facebook/zstd/releases/download/v$(ZSTD_VERSION)/zstd-$(ZSTD_VERSION).tar.gz
ZSTD_PROGRAMS := zstd
ZSTD_LIBRARIES := libzstd.a

$(eval $(call create_recipes, \
	$(NAME), \
	$(ZSTD_VERSION), \
	$(ZSTD_URL), \
	$(ZSTD_PROGRAMS), \
	$(ZSTD_LIBRARIES), \
))

# NOTE: we have to hardcode a fake UNAME otherwise it will build file extensions
# based on our host OS, not the target OS.  Also, zstd always builds both shared
# and static libraries so we must pass CFLAGS and LDFLAGS via environment variables.
# If we don't, the makefile can't append recipe-specific flags to them and it'll
# fail trying to build a static and shared library using the same flags.
# See: https://github.com/facebook/zstd/issues/3190
$(BUILD_FLAG): $$(libz)
	$(eval $(call activate_toolchain,$@))
	$(MAKE) -C "$(SRC)" clean
	CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" \
	  $(MAKE) -C "$(SRC)" UNAME="Linux"
	$(MAKE) -C "$(SRC)" install UNAME="Linux" PREFIX="$(SYSROOT)"

ALL_PROGRAMS += $(ZSTD_PROGRAMS)
DEFAULT_PROGRAMS += $(ZSTD_PROGRAMS)