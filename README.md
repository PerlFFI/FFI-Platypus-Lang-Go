# FFI::Platypus::Lang::Go ![linux](https://github.com/PerlFFI/FFI-Platypus-Lang-Go/workflows/linux/badge.svg)

Documentation and tools for using Platypus with Go

# SYNOPSIS

Go code:

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

Perl code:

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

# DESCRIPTION

This distribution is the Go language plugin for Platypus.
It provides the definition for native Go types, like
`goint` and `gostring`.  It also provides a [FFI::Build](https://metacpan.org/pod/FFI::Build)
interface for building Perl extensions written in Go.

For a full working example based on the synopsis above,
including support files like `Makefile.PL` and tests,
see the `examples/Awesome-FFI` directory that came with
this distribution.

# SEE ALSO

- [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus)

    More about FFI and Platypus itself.

- [FFI::Platypus::Type::GoString](https://metacpan.org/pod/FFI::Platypus::Type::GoString)

    Type plugin for the go string type.

- [FFI::Go::String](https://metacpan.org/pod/FFI::Go::String)

    Low level interface to the go string type.

- [FFI::Build::File::GoMod](https://metacpan.org/pod/FFI::Build::File::GoMod)

    [FFI::Build](https://metacpan.org/pod/FFI::Build) class for handling Go modules.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018-2022 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
