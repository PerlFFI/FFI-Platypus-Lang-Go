package Awesome::FFI;

use strict;
use warnings;
use FFI::Platypus;
use base qw( Exporter );

our @EXPORT_OK = qw( Add Cosine Log );

my $ffi = FFI::Platypus->new( api => 1, lang => 'Go' );
$ffi->bundle;

$ffi->type('record(Go::String)' => 'gostring');
$ffi->attach( Add    => ['goint','goint'         ] => 'goint'     );
$ffi->attach( Cosine => ['gofloat64', 'gofloat64'] => 'gofloat64' );
$ffi->attach( Log    => ['gostring'              ] => 'goint'     );

1;
