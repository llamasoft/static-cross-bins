NAME := ncurses
NCURSES_VERSION := 6.3
NCURSES_URL := https://ftp.gnu.org/gnu/ncurses/ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_PROGRAMS :=
NCURSES_LIBRARIES := libncurses.a libncurses++.a libform.a libmenu.a libpanel.a

NCURSES_CONFIG =

$(eval $(call create_recipes, \
	$(NAME), \
	$(NCURSES_VERSION), \
	$(NCURSES_URL), \
	$(NCURSES_PROGRAMS), \
	$(NCURSES_LIBRARIES), \
))

# NOTE: do not autoreconf or it can cause the build to fail.
# It emits a lot of obsolete macro warnings then the build
# spews hundreds of warnings about redefined preprocessor macros
# before finally failing for unrelated reasons.
$(BUILD_FLAG):
	$(eval $(call activate_toolchain,$@))
	cd "$(SRC)" && ./configure \
	  $(CONFIGURE_DEFAULTS) \
	  --without-manpages --without-progs --disable-ext-funcs \
	  --without-tack --without-tests --without-debug \
	  $(NCURSES_CONFIG) \
	  CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(MAKE) -C "$(SRC)" clean
	$(MAKE) -C "$(SRC)" libs
	$(MAKE) -C "$(SRC)" install.libs