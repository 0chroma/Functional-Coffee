global.__modules ||= {}
global.__protocols ||= {}
global.__default_protocol_impl ||= {}

# Polymorphism library for functional coffeescript modules

protocolMemberFn = (modName, key) ->
  (subject) ->
    # Resolve the implementation based on the subject of the function call
    # If the subject has a protocol implemented, call it
    # Otherwise use the default implementation
    if subject && implementationFn = __protocols[modName]?[subject.__struct__]?[key]
      implementation = __protocols[modName][subject.__struct__]
    else if subject && implementationFn = __protocols[modName]?[key] && subject.__struct__
      implementation = __protocols[modName]
    else
      # For cases when we either get passed something that isn't a struct
      # Or if someone is trying to be clever when they shouldn't
      throw new Error("Could not find protocol implementation!")
    # Call it in context with the arguments we got
    implementationFn.apply(implementation, arguments)

module.exports = {
  # Modules
  defmodule: (name, obj) ->
    if __modules[name]
      throw new Error("Module already defined")
    obj.__module__ = name
    for key, fn of obj
      if typeof fn is 'function'
        obj[key] = fn.bind(obj)
    __modules[name] = obj
    obj

  # Structs + Protocols for structs
  struct: (type, obj) ->
    obj.__struct__ = type
    obj
  defprotocol: (name, obj) ->
    __default_protocol_impl[name] = obj
    __protocols[name] = {}
    protocol = {}
    for key, val of obj
      if typeof val is 'function'
        protocol[key] = protocolMemberFn name, key
      else
        protocol[key] = val
    protocol

  defimpl: (name, params, obj) ->
    impl_for = params.for
    throw new Error("Protocol #{name} not found!") unless __protocols[name]
    __protocols[name][impl_for] = obj
    obj

}
