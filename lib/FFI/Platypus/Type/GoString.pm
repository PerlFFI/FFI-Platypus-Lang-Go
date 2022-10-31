package FFI::Platypus::Type::GoString;

use strict;
use warnings;
use FFI::Platypus 1.24;
use FFI::Go::String;
use Ref::Util qw( is_blessed_ref );

# ABSTRACT: Go String type for Platypus
# VERSION

=head1 SYNOPSIS

 use FFI::Platypus 1.00;
 
 my $ffi = FFI::Platypus->new( api => 1 );
 $ffi->load_custom_type('::GoString' => 'gostring');
 $ffi->function( some_go_function => [ 'gostring' ] )->call("hello there!");

=head1 DESCRIPTION

This Platypus custom types lets you pass strings transparently into Go code
without having to create/pass L<FFI::Go::String> types manually.  Under the
covers L<FFI::Go::String> is used.

The Go language plugin L<FFI::Platypus::Lang::Go> will load this custom type
automatically, so probably best to just do this:

 use FFI::Platypus 1.00;
 
 my $ffi = FFI::Platypus->new( api => 1, lang => 'Go' );
 $ffi->function( some_go_function => [ 'gostring' ] )->call("hello there!");

Functions that return a string are not supported, as calling such functions
outside of Go are not currently supported.

=cut

sub ffi_custom_type_api_1
{
  return {
    native_type => 'record(FFI::Go::String)',
    perl_to_native => sub {
      is_blessed_ref $_[0] && $_[0]->isa('FFI::Go::String')
        ? $_[0]
       : FFI::Go::String->new($_[0]);
    },
  };
}

1;
