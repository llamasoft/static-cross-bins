ifeq (openssl,$(OPENSSL))

NAME := openssl
OPENSSL_VERSION := 3.0.4
OPENSSL_URL := https://github.com/openssl/openssl/archive/refs/tags/openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_PROGRAMS := openssl
OPENSSL_LIBRARIES := libssl.a libcrypto.a

OPENSSL_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(OPENSSL_VERSION), \
	$(OPENSSL_URL), \
	$(OPENSSL_PROGRAMS), \
	$(OPENSSL_LIBRARIES), \
))

# OpenSSL decided to use a custom configure script
# that requires an OpenSSL-specific CPU target.
# If we have ARCH defined then the -march in our CFLAGS
# will generate the correct result for us.  If not,
# we need to pick the closest OpenSSL target based
# on the toolchain that we're currently using.
define get_openssl_target
ifeq (,$(OPENSSL_TARGET))
ifneq (,$(filter x86_64-%,$(TARGET)))
OPENSSL_TARGET := linux-x86_64
else ifneq (,$(filter aarch64-%,$(TARGET)))
OPENSSL_TARGET := linux-aarch64
else ifneq (,$(filter arm%,$(TARGET)))
OPENSSL_TARGET := linux-armv4
else ifneq (,$(filter mips%,$(TARGET)))
OPENSSL_TARGET := linux-mips32
else ifneq (,$(ARCH))
OPENSSL_TARGET := linux-generic32
else
$(warning Unable to detect OpenSSL target from musl toolchain $(TARGET).)
$(warning If the build fails, consider manually setting OPENSSL_TARGET.)
endif
endif
endef

$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	$(eval $(call get_openssl_target))
	cd "$(SRC)" && ./Configure \
	  --prefix="$(SYSROOT)" \
	  no-shared no-tests no-asm no-engine no-module \
	  $(OPENSSL_CONFIG) \
	  $(OPENSSL_TARGET) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)"
	$(MAKE) -C "$(SRC)" install_sw

ALL_PROGRAMS += $(OPENSSL_PROGRAMS)

endif