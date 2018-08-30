use strict;
use warnings;
use FFI::Platypus;

my $ffi = FFI::Platypus->new;
$ffi->lang('Go');

system 'go build -o osargs.so -buildmode=c-shared osargs.go';
$ffi->lib('./osargs.so');

$ffi->function(print_args => [] => 'void')->call;
