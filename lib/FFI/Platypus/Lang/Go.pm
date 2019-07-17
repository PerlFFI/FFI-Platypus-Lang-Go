package FFI::Platypus::Lang::Go;

use strict;
use warnings;
use 5.008001;
use Go::String;
use File::ShareDir::Dist 0.07 qw( dist_config );

# ABSTRACT: Documentation and tools for using Platypus with Go
# VERSION

my $config;

sub _config
{
  $config ||= dist_config 'FFI-Platypus-Lang-Go';
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
