package Twapake;

#       Twapake.pm
#
#       This file is part of twapake
#
#       Copyright 2010-2011 Frédéric Galusik <fredg~at~salixos~dot~org>
#       License: BSD Revised
#
###############################################################################

use strict;
use warnings;
use POSIX;
use File::stat;
use File::Path;

#
# The place where Slackware store installed packages log files
#
our $pkgdir = "/var/log/packages";

our $rm_command;
our $removepkg = "/sbin/removepkg";
our $spkg = "/sbin/spkg";
our $spkgd = "/sbin/spkg -d";

our $file;
our @files;
our @sortfiles;
our ( $a, $b );
our $now = localtime;
our $nowfile = strftime("%Y-%m-%d-%H-%M-%S", localtime(time));

# the place to store twapake log files
our $twa_path = "/var/log/twapake";
mkpath $twa_path, 1, 0755;

sub new {
    my $self = {};
    bless ($self);
    return $self;
}

#
# check if we use spkg or removepkg
#
sub checkrm {
    if ( -e $spkg and -e $removepkg ) {
        $rm_command = $spkgd;
        } elsif (-e $removepkg and not -e $spkg ) {
            $rm_command = $removepkg;
            } else {
                die "Nor pkgtool or spkg are installed, aborting...\n";
            }
}

#
# get the packages list
#
sub get_files {
    opendir(DIR, $pkgdir) or die "Cannot open '$pkgdir' : $!\n";
    @files = grep !/^\./, readdir(DIR);
    closedir(DIR);
    return @files;
}
get_files();

#
# get the total of installed packages
#
sub nbpkg {
    our $npkg = @files;
    return $npkg;
}

#
# build a hash with key = pkg name and value = last time modification
#
keys our %hache = @files;
foreach $file (@files) {
    our $stpkg = stat("$pkgdir/$file");
    $hache{$file} = $stpkg->mtime;
}

#
# sort hash by descending value date
#
sub sortfiles {
    @sortfiles = sort { $hache{$b} <=> $hache{$a} } @files;
    return @sortfiles;
}
sortfiles();

#
# make the twapake snapshot:
# installed date - package name
#
sub twalog {
    open(TWAFILE, ">$twa_path/${nowfile}_twapake.log");
    print TWAFILE "\nTwapake snapshot on $now\n";
    print TWAFILE '='x72 ."\n\n";
    print TWAFILE "Installed dates\t\tPackages (total: ", nbpkg(), ")\n";
    print TWAFILE '-'x19 ."\t" . '-'x45 ."\n";
    for $file (@sortfiles) {
        printf TWAFILE "%s\t%s\n",
        strftime("%Y-%m-%d %H:%M:%S", localtime($hache{$file})), $file;
    }
    close(TWAFILE);
}

#
# make a less detailed list
# give the choice of number of packages
#
our $nlpkg;
$nlpkg = nbpkg() unless defined($nlpkg);
sub checknpkg {
    if ($nlpkg > nbpkg()) {
        die "Error: only ", nbpkg(), " packages are installed.\n";
    }
}

sub sortmtimelist {
    checknpkg();
    foreach $file ( 0..($nlpkg - 1) ) {
        print "$sortfiles[$file]\n";
    }
}

#
# remove last installed packages
#
sub rmpkg {
    checknpkg();
    checkrm();
    print "Do you wish to remove all these packages ?\n";
    foreach $file ( 0..($nlpkg - 1) ) {
        print "$sortfiles[$file]\n";
    }
    print "(y)es or (n)o ? ";
    if ((my $answer = <STDIN>) =~ /^y$/i) {
        foreach $file ( 0..($nlpkg - 1) ) {
            system ("$rm_command $sortfiles[$file]");
        }
    } elsif ($answer =~ /^n$/i) {
        die "aborting ...\n";
    } else {
        chomp $answer;
        die "'$answer' is neither 'y' for 'yes' nor 'n' for 'no'\n";
    }
}

#
# show installed packages since a choosen date
#
our $choosedate;
sub userdate_default {
    my $today = strftime("%Y-%m-%d", localtime(time));
    return $today;
}
$choosedate = userdate_default() unless defined($choosedate);
sub checkdate {
    if ($choosedate =~ m!^((?:19|20)\d\d)[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])$!) {
    # $1 year $2 month $3 day
    if ($3 == 31 and ($2 == 4 or $2 == 6 or $2 == 9 or $2 == 11)) {
      die "Sorry but this month has not 31 days!\n";
    } elsif ($3 >= 30 and $2 == 2) {
      die "Sorry but February has not as much days!\n";
    } elsif ($2 == 2 and $3 == 29 and not ($1 % 4 == 0 and ($1 % 100 != 0 or $1 % 400 == 0))) {
      die "Sorry but it is not a leap year\n";
    }
  } else {
    die "Sorry but date format must be YYYY-mm-dd!\n";
  }
}

sub installedsince {
    for $file (@sortfiles) {
        if (strftime("%Y-%m-%d %H:%M:%S", localtime($hache{$file})) gt $choosedate) {
            print "$file\n";
        }
    }
}

1;
