# FFI::Platypus::Lang::Go ![static](https://github.com/PerlFFI/FFI-Platypus-Lang-Go/workflows/static/badge.svg) ![linux](https://github.com/PerlFFI/FFI-Platypus-Lang-Go/workflows/linux/badge.svg)

Documentation and tools for using Platypus with Go

# SYNOPSIS

Go code:

```
package main

import "C"

//export add
func add(x, y int) int {
    return x + y
}

func main() {}
```

Perl code:

```perl
use FFI::Platypus 2.00;
use FFI::CheckLib qw( find_lib_or_die );
use File::Basename qw( dirname );

my $ffi = FFI::Platypus->new(
  api  => 2,
  lib  => './add.so',
  lang => 'Go',
);
$ffi->attach( add => ['goint', 'goint'] => 'goint' );

print add(1,2), "\n";  # prints 3
```

# DESCRIPTION

This distribution is the Go language plugin for Platypus.
It provides the definition for native Go types, like
`goint` and `gostring`.  It also provides a [FFI::Build](https://metacpan.org/pod/FFI::Build)
interface for building Perl extensions written in Go (see
[FFI::Build::File::GoMod](https://metacpan.org/pod/FFI::Build::File::GoMod) for details).

# EXAMPLES

The examples in this discussion are bundled with this
distribution and can be found in the `examples` directory.

## Passing and Returning Integers

### Go

```
package main

import "C"

//export add
func add(x, y int) int {
    return x + y
}

func main() {}
```

### Perl

```perl
use FFI::Platypus 2.00;
use FFI::CheckLib qw( find_lib_or_die );
use File::Basename qw( dirname );

my $ffi = FFI::Platypus->new(
  api  => 2,
  lib  => './add.so',
  lang => 'Go',
);
$ffi->attach( add => ['goint', 'goint'] => 'goint' );

print add(1,2), "\n";  # prints 3
```

### Execute

```
$ go build -o add.so -buildmode=c-shared add.go
$ perl add.pl
3
```

### Discussion

The Go code has to:

- 1 Import the pseudo package `"C"`
- 2 Mark any exported function with the command `//export`
- 3 Include a `main` function, even if you do not use it.

From the Perl side, the Go types have a `go` prefix, so `int`
in Go is `goint` in Perl.

Aside from that passing basic types like integers and floats
is trivial with FFI.

## Module

### Go

```
/*
 * borrowed from
 * https://medium.com/learning-the-go-programming-language/calling-go-functions-from-other-languages-4c7d8bcc69bf
 */

package main

import "C"

import (
       "fmt"
       "math"
       "sort"
       "sync"
)

var count int
var mtx sync.Mutex

//export Add
func Add(a, b int) int { return a + b }

//export Cosine
func Cosine(x float64) float64 { return math.Cos(x) }

//export Sort
func Sort(vals []int) { sort.Ints(vals) }

//export Log
func Log(msg string) int {
       mtx.Lock()
       defer mtx.Unlock()
       fmt.Println(msg)
       count++
       return count
}

func main() {}
```

### Perl

Module:

```perl
package Awesome::FFI;

use strict;
use warnings;
use FFI::Platypus;
use FFI::Go::String;
use base qw( Exporter );

our @EXPORT_OK = qw( Add Cosine Log );

my $ffi = FFI::Platypus->new( api => 1, lang => 'Go' );
# See FFI::Platypus::Bundle for the how and why
# bundle works.
$ffi->bundle;

$ffi->attach( Add    => ['goint','goint'] => 'goint'     );
$ffi->attach( Cosine => ['gofloat64'    ] => 'gofloat64' );
$ffi->attach( Log    => ['gostring'     ] => 'goint'     );

1;
```

Test:

```perl
use Test2::V0 -no_srand => 1;
use Awesome::FFI qw( Add Cosine Log );
use Capture::Tiny qw( capture );
use FFI::Go::String;

is( Add(1,2), 3 );
is( Cosine(0), 1.0 );

is(
  [capture { Log("Hello Perl!") }],
  ["Hello Perl!\n", '', 1]
);

done_testing;
```

### Execute

```
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
```

### Discussion

This is a full working example of a Perl distribution / module
included in the `examples/Awesome-FFI` directory.

# SEE ALSO

- [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus)

    More about FFI and Platypus itself.

- [FFI::Platypus::Type::GoString](https://metacpan.org/pod/FFI::Platypus::Type::GoString)

    Type plugin for the go string type.

- [FFI::Go::String](https://metacpan.org/pod/FFI::Go::String)

    Low level interface to the go string type.

- [FFI::Build::File::GoMod](https://metacpan.org/pod/FFI::Build::File::GoMod)

    [FFI::Build](https://metacpan.org/pod/FFI::Build) class for handling Go modules.

- [Calling Go Functions from Other Languages using C Shared Libraries](https://github.com/vladimirvivien/go-cshared-examples)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018-2022 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
