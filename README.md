# FFI::Platypus::Lang::Go [![Build Status](https://travis-ci.org/Perl5-FFI/FFI-Platypus-Lang-Go.svg)](http://travis-ci.org/Perl5-FFI/FFI-Platypus-Lang-Go)

Documentation and tools for using Platypus with Go

# METHODS

## native\_type\_map

```perl
my $hash = FFI::Platypus::Lang::Go->native_type_map;
```

This returns a hash reference containing the native aliases for
Go.  That is the keys are native Go types and the values are
[FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) types.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
