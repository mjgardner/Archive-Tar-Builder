#!/usr/bin/env perl

# Copyright (c) 2016, cPanel, Inc.
# All rights reserved.
# http://cpanel.net/
#
# This is free software; you can redistribute it and/or modify it under the same
# terms as Perl itself.  See the LICENSE file for further details.

use strict;
use warnings;
use English '-no_match_vars';

use Test::More tests => 2;
use Test::TempDir::Tiny;

use Archive::Tar::Builder;
use Archive::Tar;
use Archive::Tar::Constant;
use File::Temp;
use IO::All;
use List::MoreUtils 'part';

my $path_separator = '/';
my @paths = map { join $path_separator => ( $_ x 10 ) x 20 } qw(x y);

subtest 'Archive::Tar' => sub {
    my $tar  = Archive::Tar->new;
    my @file = (
        $tar->add_data( $paths[0], q{}, { type => FILE } ),
        $tar->add_data(
            $paths[1],
            q{},
            {
                type     => SYMLINK,
                linkname => $paths[0],
            }
        ),
    );

    test_tar_list( $tar, @paths );
};

subtest 'Archive::Tar::Builder' => sub {
    my $temp_dir = tempdir($PROGRAM_NAME);

    my   @file = ( io->catfile( $temp_dir, $paths[0] )->assert->touch );
    push @file =>  io->catfile( $temp_dir, $paths[1] )->link->assert;

    my $link_target = $file[0]->pathname;
    $link_target =~ s/^$temp_dir\///;
    $file[1]->symlink($link_target);

    for my $extension_type (qw(gnu posix)) {
        subtest uc $extension_type => sub {
            my $tar_file  = File::Temp->new;
            my $tar_build = Archive::Tar::Builder->new(
                "${extension_type}extensions" => 1,
            );
            $tar_build->set_handle($tar_file);

            my %tar_list;
            for (@file) {
                $tar_list{$_} = $_;
                $tar_list{$_} =~ s/^$temp_dir\///;
            }
            ok( $tar_build->archive_as(%tar_list), 'built tar' );
            $tar_build->finish;

            my $tar = Archive::Tar->new("$tar_file");
            test_tar_list( $tar, @paths );
        };
    }
};

sub test_tar_list {
    my ( $tar, @path ) = @_;

    my @tar_list = part { $_->{type} }
        $tar->list_files( [qw(type prefix name linkname)] );
    diag explain grep { defined } @tar_list;

    is(
        $tar_list[SYMLINK][0]{linkname},
        join( $path_separator => @{ $tar_list[FILE][0] }{qw(prefix name)} ),
        'symlink destination name',
    );
}
