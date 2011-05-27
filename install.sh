#!/bin/sh

PERLVER=5.12.3
PERLDIR=usr/lib${LIBDIRSUFFIX}/perl5/$PERLVER

install -D -m 755 twapake $DESTDIR/usr/sbin/twapake
install -D -m 644 Twapake.pm $DESTDIR/$PERLDIR/Twapake/Twapake.pm
install -D -m 644 Twacurse.pm $DESTDIR/$PERLDIR/Twapake/Twacurse.pm
install -D -m 755 twapake.cron $DESTDIR/etc/cron.daily/twapake
install -D -m 644 twapake.man $DESTDIR/usr/man/man8/twapake.8
