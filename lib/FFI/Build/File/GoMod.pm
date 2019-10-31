package FFI::Build::File::GoMod;

use strict;
use warnings;
use 5.008001;
use base qw( FFI::Build::File::Base );
use constant default_suffix => '.mod';
use constant default_encoding => ':utf8';
use Path::Tiny ();
use FFI::Build::Platform;
use FFI::Build::File::Library;
use File::chdir;

# ABSTRACT: Class to track C source file in FFI::Build
# VERSION

=head1 SYNOPSIS

 use FFI::Build::File::GoMod;
 
 my $c = FFI::Build::File::GoMod->new('src/go.mod');

=head1 DESCRIPTION

File class for Go Modules.

=cut
  
sub accept_suffix
{
  (qr/\/go\.mod$/)
}

sub build_all
{
  my($self) = @_;
  $self->build_item;
}

sub build_item
{
  my($self) = @_;

  my $gomod = Path::Tiny->new($self->path);

  my $platform;
  my $buildname;
  my $lib;

  if($self->build)
  {
    $platform = $self->build->platform;
    $buildname = $self->build->buildname;
    $lib = $self->build->file;
  }
  else
  {
    $platform = FFI::Build::Platform->new;
    $buildname = "_build";
    $lib = FFI::Build::File::Library->new(
      [
        $gomod->parent->child($buildname).'',
        do {
          my($name) = map { my $m = $_; $m =~ s/\s*$//; lc $m }
                      map { my $m = $_; $m =~ s/^.*\///; $m }
                      grep /^module /,
                      $gomod->lines_utf8;
          $name = "gomod" unless defined $name;
          join '', $platform->library_prefix, $name, scalar $platform->library_suffix
        },
      ],
      platform => $self->platform
    );
  }

  {
    my $lib_path = Path::Tiny->new($lib->path)->absolute;
    local $CWD = $gomod->parent;
    $platform->run('go', 'build', -o => "$lib_path", '-buildmode=c-shared');
    die "no c-shared library" unless -f $lib_path;
    chmod 0755, $lib_path unless $^O eq 'MSWin32';
  }

  $lib;
}

1;
