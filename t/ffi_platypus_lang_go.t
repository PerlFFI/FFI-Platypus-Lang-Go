use Test2::V0 -no_srand => 1;
use FFI::Platypus::Lang::Go;
use FFI::Platypus;

subtest 'basic' => sub {

  my $ffi = FFI::Platypus->new;
  $ffi->lang('Go');

  my @types = qw(
    bool
    string
    int  int8  int16  int32  int64
    uint uint8 uint16 uint32 uint64 uintptr
    byte
    rune
    float32 float64
  );

  # support depends on C, libffi, etc
  # complex64 complex128

  foreach my $type (@types)
  {
    my $size = eval { $ffi->sizeof($type) };
    is $@, '', "size of $type == @{[ $size || 'undef' ]}";
  }

};

done_testing
