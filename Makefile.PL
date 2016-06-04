require 'mk/MY.pm';
require 'mk/MY/Makefile.pm';

my $makefile = MY::Makefile->new(
    'srcdir'        => 'src',
    'scan_manifest' => 1
);

$makefile->write(
    'NAME'         => 'Archive::Tar::Builder',
    'VERSION_FROM' => 'lib/Archive/Tar/Builder.pm',
    'AUTHOR'       => 'Erin Schoenhals <erin@cpanel.net>',
    'LICENSE'      => 'perl',
    'ABSTRACT'     => 'Provides a braindead tarball builder thingie',
    'PMLIBDIRS'    => ['lib'],
    'CCFLAGS'      => '-D_FILE_OFFSET_BITS=64',

    'PREREQ_PM'      => {},
    'BUILD_REQUIRES' => {
        'Test::Simple'    => '0.44',
        'Test::Exception' => 0,
    },
    'TEST_REQUIRES' => {
        'Test::More'             => 0,
        'Test::TempDir::Tiny'    => 0,
        'Archive::Tar'           => 0,
        'Archive::Tar::Constant' => 0,
        'File::Temp'             => 0,
        'IO::All'                => 0,
        'List::MoreUtils'        => 0,
    },
);
