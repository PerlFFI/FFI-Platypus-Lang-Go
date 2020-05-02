package FFI::Platypus::Lang::Go;

use strict;
use warnings;
use 5.008001;
use File::ShareDir::Dist 0.07 qw( dist_config );

# ABSTRACT: Documentation and tools for using Platypus with Go
# VERSION

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

=head1 METHODS

=head2 native_type_map

 my $hash = FFI::Platypus::Lang::Go->native_type_map;

This returns a hash reference containing the native aliases for
Go.  That is the keys are native Go types and the values are
L<FFI::Platypus> types.

=cut

sub native_type_map
{
  _config->{go_types};
}

1;
