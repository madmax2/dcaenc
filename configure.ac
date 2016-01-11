AC_INIT([dcaenc], [2], [patrakov@gmail.com], [],
        [http://aepatrakov.narod.ru/dcaenc/])
AC_CONFIG_SRCDIR([src/dcaenc.c])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([build-aux])
AC_CONFIG_AUX_DIR([build-aux])

AM_INIT_AUTOMAKE([-Wall -Werror dist-bzip2 dist-xz foreign check-news])
AM_SILENT_RULES([yes])

AM_PROG_AR
LT_INIT([disable-static win32-dll])

# Checks for programs.
AC_PROG_CC
PKG_PROG_PKG_CONFIG

# Checks for libraries.
AC_ARG_ENABLE([alsa], AS_HELP_STRING([--disable-alsa], [disable building of ALSA plugin]))

ac_save_LIBS="$LIBS"

AS_IF([test "x$enable_alsa" != "xno"], [
    PKG_CHECK_MODULES([ALSA], [alsa >= 1.0.11], [HAVE_ALSA=yes], [HAVE_ALSA=no])
    AC_CHECK_LIB([asound], [snd_pcm_extplug_create],
                 [HAVE_ALSA=yes], [HAVE_ALSA=no], [-ldl])
	AS_IF([test "x$enable_alsa" = "xyes" -a "x$HAVE_ALSA" = "xno"], [
        AC_MSG_ERROR([ALSA libraries not found])
    ])
])
AM_CONDITIONAL([HAVE_ALSA], [test "x$enable_alsa" != "xno" -a "x$HAVE_ALSA" = "xyes"])
LIBS="$ac_save_LIBS"

# Checks for library functions.
ac_save_LIBS="$LIBS"
LT_LIB_M
LIBS="$ac_save_LIBS"

AC_CONFIG_FILES([Makefile
                 man/Makefile
                 src/Makefile
                 dcaenc.pc])
AC_OUTPUT
