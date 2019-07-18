use strict;
use warnings;
use 5.010;
use FFI::Platypus;
use Go::String;

my $ffi = FFI::Platypus->new(
  api          => 1,
  experimental => 1,
  lang         => 'Go',
  lib          => './awesome.so',
);

$ffi->type('record(Go::String)' => 'gostring');
$ffi->attach( Add    => ['goint','goint'         ] => 'goint'     );
$ffi->attach( Cosine => ['gofloat64', 'gofloat64'] => 'gofloat64' );
$ffi->attach( Log    => ['gostring'              ] => 'goint'     );

say "awesome.Add(12, 99) = @{[ Add(12, 99) ]}";
say "awesome.Cosine(1) = @{[ Cosine(1) ]}";

# TODO: sort/slice

my $gostr = Go::String->new("Hello Perl!");
Log($gostr);
