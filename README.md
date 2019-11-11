# Minimalist Ruby Hawk Authorization Client and Faraday Middleware

Apparently tent's [hawk-ruby](https://github.com/tent/hawk-ruby) is dead and has been archived by its
author.

I needed a working Hawk client implementation in Ruby in order to leverage the
api from [ThreatStack](https://www.threatstack.com).

This is a minimalist Ruby version of the Hawk authentication scheme. An attempt
has been made to write this in idiomatic Ruby, rather than as a copy of the
JavaScript. The specs here are mostly based on the tests for hapji/hawk v7.1.1
([f455587](https://github.com/hapijs/hawk/tree/f455587c08c46d7249e334a4fe5fb70230e6bc3b)),
which is the authoritative implementation. I've cross-referenced the specs here
with links to similar tests in the JavaScript.

My major departures from the style of the JavaScript Hawk implementation are:

1. As much as possilble, if there is state that can be shared across multiple generations
   of headers or authorization verifications, that state is set up during object
   instantiation with the regular `.initialize` method.
2. Anything request-specific is passed as parameters to the `#header` and `#authenticate`
   methods.
3. For the most part, the raising of exceptions when surprising types are encountered has
   been removed in favor of duck-typing.

In other words, when a session is started, you create an instance of `Client`. Then when
you need to make a request, you pass anything specific to the request (resource, method, etc.)
to `#header`. Most likely, you are not going to call these methods directly, but will
use the included Faraday middlware.

## Usage / How it works

To understand usage, consult the [hapji/hawk documentation](https://hapi.dev/family/hawk/).

## Faraday Middleware

This gem provides a Faraday Middleware called `Hawkify` so that you can add the Hawk header
to outgoing requests, as well as authenticate server responses.

If you want to authenticate responses from the server, note that `Hawkify` must get access
to the raw body returned from the server. When you initialize Faraday, set the request option
for `preserve_raw` for example:

    Faraday.new(url: 'https://api.threatstack.com', request: { preserve_raw: true } )

## TODO

* Spec out the Faraday middleware

## Not included

* server and plugin
* implementation of the client `#message` function (which doesn't seem to be public or used)
* [`bewit`](https://github.com/hapijs/hawk#bewit-strategy) support
* [splitting of the content-type](https://github.com/hapijs/hawk/blob/master/lib/utils.js#L53)
  (if the JavaScript client specs had tested this, I might have considered it.)
* Support for clock-drift.
