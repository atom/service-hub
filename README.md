# service-hub [![Build Status](https://travis-ci.org/atom/service-hub.svg?branch=master)](https://travis-ci.org/atom/service-hub)

A semantically versioned provider/consumer system for global application services.

The `order-pizza` library wants to provide a global service for use by other
modules in the application. It calls provide on a global `ServiceHub` instance
with the name of the service and the current semantic version of the API:

```coffee
# Provider

global.services.provide "order-pizza", "1.0.0",
  placeOrder: (size, topping) -> # ...
```

Then two other libraries *consume* this service, ensuring they are compatible
with its API by specifying a version range:

```coffee
# Consumer 1

workingLate: ->
  global.services.consume "order-pizza", "^1.0.0", (orderPizza) ->
    orderPizza.placeOrder("medium", "four cheese")

# Consumer 2

burntDinner: ->
  global.services.consume "order-pizza", "^1.0.0", (orderPizza) ->
    orderPizza.placeOrder("large", "pepperoni")
```

Now the author of the `order-pizza` makes a breaking change to the API. They
start providing another instance of the service associated with the next major
version number, converting the old service to a shim for compatibility:

```coffee
# Provider

placeOrder = ({size, toppings}) -> # ...

# Providing the new API
global.services.provide "order-pizza", "2.0.0", {placeOrder}

# Shimming the old API
global.services.provide "order-pizza", "1.0.0",
  placeOrder: (size, topping) ->
    placeOrder({size, toppings: [topping]})
```

If at some point the API changed so drastically that it wasn't possible to shim
previous versions, at least the outdated consumers wouldn't use the new API
incorrectly. They would just fail to discover the service.
