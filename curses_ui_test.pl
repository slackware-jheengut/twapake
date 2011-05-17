#!/usr/bin/env perl
use strict;
use warnings;

use Curses::UI;

my $cui = new Curses::UI ( -clear_on_exit => 1, -color_support => 1);

my $win1 = $cui->add(
       'win1', 'Window',
       -title           =>
        'Twapake - Select packages for removal (^X for Menu)',
       -titlereverse    => 0,
       -padtop          => 1,
       -border          => 1,
       -ipad            => 1,
       -bold            => 0,
       -y               => 1,
       -bfg             => 'red',
);

## READ DATA
my $pkgdir = "/home/fredg";
my @files;
sub get_files {
    opendir(DIR, $pkgdir) or die "Cannot open '$pkgdir' : $!\n";
    @files = grep !/^\./, readdir(DIR);
    closedir(DIR);
    return @files;
}
get_files();

my @menu = (
    { -label => 'Menu',
      -submenu => [
        { -label => 'Remove selected packages   ^R',
          -value => \&remove_pkg },
        { -label => 'Unselect All packages      ^U',
          -value => \&unselectall },
        { -label => 'Exit                       ^Q',
          -value => \&exit_dialog }
    ]
    },
);

my $menu = $cui->add(
    'menu','Menubar',
    -menu => \@menu,
);

$cui->set_binding(sub {$menu->focus()}, "\cX");
$cui->set_binding( \&exit_dialog , "\cQ");
$cui->set_binding( \&remove_pkg , "\cR");
$cui->set_binding( \&unselectall , "\cU");

my $listpkgbox = $win1->add(
       'listpkgbox', 'Listbox',
       -width     => 50,
       -y         => 1,
       -x         => 10,
       -values    => \@files,
       -multi     => 1,
       -intellidraw => 1,
);

$listpkgbox->focus();

sub unselectall {
    $listpkgbox->clear_selection();
    $listpkgbox->draw();
    return;
}

sub exit_dialog {
    my $return = $cui->dialog(
        -message   => "Do you really want to quit?",
        -title     => "Are you sure???",
        -bfg             => 'red',
        -buttons   => ['yes', 'no'],
    );
    exit(0) if $return;
}

sub remove_pkg {
    my $yesrm = $cui->dialog(
        -message   => "Do you really want to remove ?",
        -title     => "Are you sure???",
        -bfg             => 'red',
        -buttons   => ['yes', 'no'],
    );
    if ($yesrm) {
        my @selected = $listpkgbox->get();
        for my $sel (@selected) {
            system ("rm $pkgdir/$sel");
            }
        sleep(1);
        get_files();
        unselectall();
        }
    }

$cui->mainloop();
