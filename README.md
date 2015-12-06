# Functional Coffee

Based off of the module-protocol pattern in [Elixir](http://elixir-lang.org/)

## Usage

Meant to co-exist with your existing module system. In this example we'll use node's built-in modules.

To define a protocol:

```coffeescript
{defprotocol} = require './functional'

module.exports = defprotocol "Stream", {
  next: -> # default implementation would go here
}
```

To define a module and a protocol implementation:

```coffeescript
{defmodule, defimpl, struct} = require './functional'

module.exports = defmodule "EndlessStream", {
  create: (value) ->
    struct @__module__, {
      value
    }
}

defimpl "Stream", for: "EndlessStream", {
  next: (stream) ->
    stream.value # emits the value passed in through create endlessly
}
```

To use a module/protocol:
```coffeescript
Stream = require './Stream'
EndlessStream = require './EndlessStream'

s = EndlessStream.create "Hello, world!"
for num in [1..10]
  console.log Stream.next(s)
```
The subject (fancy word for first argument) of a function for any protocol call should be a struct so that we can look up it's corresponding implementation.
