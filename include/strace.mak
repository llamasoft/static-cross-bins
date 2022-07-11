NAME := strace
STRACE_VERSION := 5.18
STRACE_URL := https://github.com/strace/strace/releases/download/v$(STRACE_VERSION)/strace-$(STRACE_VERSION).tar.xz
STRACE_PROGRAMS := strace
STRACE_LIBRARIES :=

STRACE_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(STRACE_VERSION), \
	$(STRACE_URL), \
	$(STRACE_PROGRAMS), \
	$(STRACE_LIBRARIES), \
))

HAVE_SED_R := $(shell sed -r '' </dev/null 2>/dev/null && echo OK)
HAVE_GSED := $(shell command -v gsed)

# NOTE: strace's INSTALL guide specifically requests _not_ using autoreconf
# in favor of using their bootstrap script.  Instead, we'll do neither.
# Also, we use --enable-mpers=no by default as it requires gawk.
$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
ifeq (,$(HAVE_SED_R))
ifneq (,$(HAVE_GSED))
# The makefiles and shell scripts make extensive use of GNU sed -r.
# BSD sed's -E flag almost does the same thing except that \n in
# replacements becomes a literal "n" instead of a newline.
# Unfortunately, strace makes extensive use of this feature,
# so GNU sed is required one way or another.
# The irony of using sed to fix sed commands is not lost on me.
	if ! sed -r "" /dev/null &>/dev/null; then \
	  for pattern in "Make*" "*.sh"; do \
	    find "$(SRC)" -type f -name "$${pattern}" \
	    | xargs grep -lF "sed -r" \
	    | xargs sed -i".bak" "s/sed -r/gsed -r/g"; \
	  done \
	fi
endif
endif
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --enable-mpers=no \
	  $(STRACE_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)"
	$(MAKE) -C "$(SRC)" install-exec

# strace can't be built on aarch64 due to a bug in linux-headers-4.19.
# Once musl-cross-make supports linux-headers-4.20 or newer, this can be removed.
# See: https://www.mail-archive.com/qemu-devel@nongnu.org/msg863832.html
ifeq (,$(findstring aarch64,$(TARGET)))
ifneq (,$(HAVE_SED_R)$(HAVE_GSED))
ALL_PROGRAMS += $(STRACE_PROGRAMS)
endif
endif