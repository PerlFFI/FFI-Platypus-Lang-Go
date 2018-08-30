use strict;
use warnings;
use Capture::Tiny qw( capture capture_merged );
use File::ShareDir::Dist::Install qw( install_config_set );
use File::chdir;
use File::Temp qw( tempdir );
use Path::Tiny qw( path );
use FFI::Platypus;

my $dist = 'FFI-Platypus-Lang-Go';

{
  my($out, $err, $exit) = capture {
    system 'go' ,'version';
  };

  unless($exit == 0)
  {
    print "This dist requires Google Go to be installed";
    exit 2;
  }

  my($version, $arch) = $out =~ /go version (\S+) (\S+)/;

  print "Found go @{[ $version || '???' ]}\n";
  print "For arch @{[ $arch || '???' ]}\n";

  install_config_set $dist, go_version => $version;
  install_config_set $dist, go_arch    => $arch;
}

# TODO: string
# uint* types are already understood by Platypus

my %types = qw(
  int8       sint8
  int16      sint16
  int32      sint32
  int64      sint64
  byte       uint8
  rune       sint32
  float32    float
  float64    double
);

{
  local $CWD = tempdir( CLEANUP => 1, DIR => '.' );
  path('simple.go')->spew(<<'EOF');
package main
import "C"
import "unsafe"

var mybool bool
//export SizeOfBool
func SizeOfBool() uintptr { return unsafe.Sizeof(mybool) }

var myint int
//export SizeOfInt
func SizeOfInt() uintptr { return unsafe.Sizeof(myint) }

var myuint uint
//export SizeOfUint
func SizeOfUint() uintptr { return unsafe.Sizeof(myuint) }

func main() {}
EOF

  my($out, $exit) = capture_merged {
    my @cmd = qw( go build -o simple.so -buildmode=c-shared simple.go );
    print "+ @cmd\n";
    system @cmd;
  };

  if($exit)
  {
    print "error building simple c-shared file\n";
    print $out;
    exit 2;
  }

  unless(-f 'simple.so')
  {
    print "Command returned success, but did not create a c-shared file\n";
    print $out;
    exit 2;
  }

  my $ffi = FFI::Platypus->new;
  $ffi->lib('./simple.so');

  $types{bool}    = 'uint' . ($ffi->function( SizeOfBool => [] => 'size_t' )->call * 8);
  $types{int}     = 'sint' . ($ffi->function( SizeOfInt => [] => 'size_t' )->call * 8);
  $types{uint}    = 'uint' . ($ffi->function( SizeOfUint => [] => 'size_t' )->call * 8);
  $types{uintptr} = 'uint' . ($ffi->sizeof('size_t')*8);

  if(eval { $ffi->sizeof('complex_float'); 1 })
  {
    $types{complex64} = 'complex_float';
  }

  if(eval { $ffi->sizeof('complex_double'); 1 })
  {
    $types{complex128} = 'complex_double';
  }
}

install_config_set $dist, go_types => \%types;
