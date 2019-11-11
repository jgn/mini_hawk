# Testing strategy for mini-hawk

The specs here imitate the tests in hapji/hawk v7.1.1 ([f455587](https://github.com/hapijs/hawk/tree/f455587c08c46d7249e334a4fe5fb70230e6bc3b)).

I have rewritten the specs to follow idiomatic Ruby and RSpec.

One area where this implementation does not match the semantics of the JavaScript
client is in error handling: The JavaScript handling is pretty crude and I've
tried to be a bit more specific with the Ruby. The JavaScript code is also
not very friendly to Ruby duck-typing so I have been a bit more lenient than
the JavaScript tests.

I am tempted to rip out all of the specs and fussiness concerning valid options.
