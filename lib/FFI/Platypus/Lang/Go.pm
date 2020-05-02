package FFI::Platypus::Lang::Go;

use strict;
use warnings;
use 5.008001;
use File::ShareDir::Dist 0.07 qw( dist_config );

# ABSTRACT: Documentation and tools for using Platypus with Go
# VERSION

=head1 SYNOPSIS

Go code:

# EXAMPLE: examples/Awesome-FFI/ffi/main.go

Perl code:

# EXAMPLE: examples/Awesome-FFI/lib/Awesome/FFI.pm

=head1 DESCRIPTION

This distribution is the Go language plugin for Platypus.
It provides the definition for native Go types, like
C<goint> and C<gostring>.  It also provides a L<FFI::Build>
interface for building Perl extensions written in Go.

For a full working example based on the synopsis above,
including support files like C<Makefile.PL> and tests,
see the C<examples/Awesome-FFI> directory that came with
this distribution.

=head1 SEE ALSO

=over 4

=item L<FFI::Platypus>

More about FFI and Platypus itself.

=item L<FFI::Platypus::Type::GoString>

Type plugin for the go string type.

=item L<FFI::Go::String>

Low level interface to the go string type.

=item L<FFI::Build::File::GoMod>

L<FFI::Build> class for handling Go modules.

=back

=cut


my $config;

sub _config
{
  unless($config)
  {
    $config = dist_config 'FFI-Platypus-Lang-Go';
    # running out of an unbuilt git, probe for types on the fly
    if(!%$config && -f 'inc/mymm-build.pl')
    {
      my $clean = 0;
      if(!-f 'blib')
      {
        require Capture::Tiny;
        my($out, $exit) = Capture::Tiny::capture_merged(sub {
          my @cmd = ($^X, 'inc/mymm-build.pl');
          print "+@cmd\n";
          system @cmd;
        });
        if($exit)
        {
          require File::Path;
          File::Path::rmtree('blib',0,0);
          print STDERR $out;
          die "probe of go types failed";
        }
        else
        {
          $clean = 1;
        }
      }
      $config = do './blib/lib/auto/share/dist/FFI-Platypus-Lang-Go/config.pl';
      if($clean)
      {
        require File::Path;
        File::Path::rmtree('blib',0,0);
      }
    }
  }

  $config;
}

sub native_type_map
{
  _config->{go_types};
}

sub load_custom_types
{
  my(undef, $ffi) = @_;
  $ffi->load_custom_type('::GoString' => 'gostring');
}

1;
