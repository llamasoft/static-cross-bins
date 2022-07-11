NAME := readline
READLINE_VERSION := 8.1.2
READLINE_URL := https://ftp.gnu.org/gnu/readline/readline-$(READLINE_VERSION).tar.gz
READLINE_PROGRAMS :=
READLINE_LIBRARIES := libreadline.a libhistory.a

READLINE_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(READLINE_VERSION), \
	$(READLINE_URL), \
	$(READLINE_PROGRAMS), \
	$(READLINE_LIBRARIES), \
))

$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --disable-shared --enable-static \
	  --disable-install-examples \
	  $(READLINE_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)"
	$(MAKE) -C "$(SRC)" install