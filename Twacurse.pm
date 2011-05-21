package Twacurse;
use strict;
use warnings;

use Curses::UI;
use Twapake;

our $cui;
our $listpkgbox;

sub uic {
    $cui = new Curses::UI ( -clear_on_exit => 1,
                            -color_support => 1,
                            -mouse_support => 0,
                            );
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

    my @menu = (
        { -label => 'Menu',
          -submenu => [
            { -label => 'Remove selected packages   ^R',
              -value => \&remove_pkg },
            { -label => 'Unselect All packages      ^U',
              -value => \&unselect_all },
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
    $cui->set_binding( \&unselect_all , "\cU");

    $listpkgbox = $win1->add(
       'listpkgbox', 'Listbox',
       -width     => 50,
       -y         => 1,
       -x         => 10,
       -values    => \@Twapake::sortfiles,
       -multi     => 1,
       -intellidraw => 1,
    );

    $listpkgbox->focus();

    $cui->mainloop();
}

sub unselect_all {
    $listpkgbox->clear_selection();
    $listpkgbox->draw();
    return;
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
            system ("$Twapake::rm_command $sel");
            }
        sleep(1);
        Twapake::get_files();
        }
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

1;
