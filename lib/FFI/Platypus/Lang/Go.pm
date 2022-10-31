package FFI::Platypus::Lang::Go;

use strict;
use warnings;
use 5.008001;
use File::ShareDir::Dist 0.07 qw( dist_config );

# ABSTRACT: Documentation and tools for using Platypus with Go
# VERSION

=head1 SYNOPSIS

Go code:

# EXAMPLE: examples/add.go

Perl code:

# EXAMPLE: examples/add.pl

=head1 DESCRIPTION

This distribution is the Go language plugin for Platypus.
It provides the definition for native Go types, like
C<goint> and C<gostring>.  It also provides a L<FFI::Build>
interface for building Perl extensions written in Go (see
L<FFI::Build::File::GoMod> for details).

=head1 EXAMPLES

The examples in this discussion are bundled with this
distribution and can be found in the C<examples> directory.

=head2 Passing and Returning Integers

=head3 Go

# EXAMPLE: examples/add.go

=head3 Perl

# EXAMPLE: examples/add.pl

=head3 Execute

 $ go build -o add.so -buildmode=c-shared add.go
 $ perl add.pl
 3

=head3 Discussion

The Go code has to:

=over 4

=item 1 Import the pseudo package C<"C">

=item 2 Mark any exported function with the command C<//export>

=item 3 Include a C<main> function, even if you do not use it.

=back

From the Perl side, the Go types have a C<go> prefix, so C<int>
in Go is C<goint> in Perl.

Aside from that passing basic types like integers and floats
is trivial with FFI.

=head2 Module

=head3 Go

# EXAMPLE: examples/Awesome-FFI/ffi/main.go

=head3 Perl

Module:

# EXAMPLE: examples/Awesome-FFI/lib/Awesome/FFI.pm

Test:

# EXAMPLE: examples/Awesome-FFI/t/awesome_ffi.t

=head3 Execute

 $ prove -lvm t/awesome_ffi.t
 t/awesome_ffi.t ..
 ok 1
 ok 2
 ok 3
 1..3
 ok
 All tests successful.
 Files=1, Tests=3,  1 wallclock secs ( 0.01 usr  0.00 sys +  1.28 cusr  0.48 csys =  1.77 CPU)
 Result: PASS

=head3 Discussion

This is a full working example of a Perl distribution / module
included in the C<examples/Awesome-FFI> directory.

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

=item L<Calling Go Functions from Other Languages using C Shared Libraries|https://github.com/vladimirvivien/go-cshared-examples>

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
