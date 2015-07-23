{Disposable} = require 'event-kit'
ServiceHub = require '../src/service-hub'

describe "ServiceHub", ->
  hub = null

  beforeEach ->
    hub = new ServiceHub

  onNextTick = (fn) ->
    waits(1)
    runs(fn)

  describe "::consume(keyPath, versionString, callback)", ->
    it "invokes the callback with each existing service that matches the key path and version range", ->
      hub.provide "a", "1.0.0", w: 1
      hub.provide "b", "1.0.0", x: 2

      services = []
      hub.consume "a", "^1.0.0", (service) -> services.push(service)

      hub.provide "a", "1.1.0", y: 3
      hub.provide "b", "1.2.0", z: 4

      expect(services).toEqual []
      onNextTick ->
        expect(services).toEqual [{w: 1}, {y: 3}]

    it "invokes the callback with the newest version of a service provided in a given batch", ->
      hub.provide "a",
        "1.0.0": {w: 1}
        "1.1.0": {x: 2}
      hub.provide "a",
        "1.2.0": {y: 3}
      hub.provide "b",
        "1.0.0": {z: 4}

      services = []
      hub.consume "a", "^1.0.0", (service) -> services.push(service)

      expect(services).toEqual []
      onNextTick ->
        expect(services).toEqual [{x: 2}, {y: 3}]

    it "invokes the callback when a new service is provided that matches the key path and version range", ->
      services = []
      hub.consume "a", "^1.0.0", (service) -> services.push(service)

      onNextTick ->
        expect(services).toEqual []

        hub.provide "a", "1.0.0", x: 1
        hub.provide "a", "1.1.0", y: 2
        hub.provide "b", "1.0.0", z: 3

        expect(services).toEqual [{x: 1}, {y: 2}]

    it "can specify a key path that navigates into the contents of a service", ->
      hub.provide "a", "1.0.0", b: c: 1
      hub.provide "a", "1.0.0", d: e: 2

      services = []
      hub.consume "a.b", "^1.0.0", (service) -> services.push(service)

      onNextTick ->
        expect(services).toEqual [{c: 1}]

    it "can specify a key path that's shorter than the key path passed to ::provide", ->
      hub.provide "a.b", "1.0.0", c: 1
      hub.provide "a.d", "1.0.0", e: 2

      services = []
      hub.consume "a", "^1.0.0", (service) -> services.push(service)

      onNextTick ->
        expect(services).toEqual [{b: c: 1}, {d: e: 2}]

  describe "disposing of a consumer", ->
    it "does not invoke the consumer callback for any pending or newly-added providers", ->
      services = []
      disposable = hub.consume "a", "^1.0.0", (service) -> services.push(service)

      hub.provide "a", "1.0.0", x: 1

      disposable.dispose()

      hub.provide "a", "1.0.1", y: 2

      onNextTick ->
        expect(services).toEqual []

  describe "disposing of a provider", ->
    it "does not invoke the callbacks of any pending or newly-added consumers", ->
      disposable1 = hub.provide "a", "1.0.0", x: 1
      disposable2 = hub.provide "a", "1.1.0", y: 2

      services1 = []
      hub.consume "a", "^1.0.0", (service) -> services1.push(service)

      disposable1.dispose()

      services2 = []
      hub.consume "a", "^1.0.0", (service) -> services2.push(service)

      onNextTick ->
        expect(services1).toEqual [{y: 2}]
        expect(services2).toEqual [{y: 2}]

    it "disposes of consumer Disposables", ->
      provideDisposable = hub.provide "a", "1.0.0", x: 1

      teardownConsumerSpy1 = jasmine.createSpy('teardownConsumer1')
      teardownConsumerSpy2 = jasmine.createSpy('teardownConsumer2')

      hub.consume "a", "^1.0.0", (service) -> new Disposable(teardownConsumerSpy1)
      hub.consume "a", "^1.0.0", (service) -> new Disposable(teardownConsumerSpy2)

      onNextTick ->
        provideDisposable.dispose()

        expect(teardownConsumerSpy1).toHaveBeenCalled()
        expect(teardownConsumerSpy2).toHaveBeenCalled()
