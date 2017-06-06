Promise = require "bluebird"
expect = require "expect"
lcp = require "../src/lru-cache-promise"

testKey = "some key"
testValue =
  stuff: "things"

describe "lru-cache-promise tests", ->
  describe "getAsync", ->
    context "when the key exists", ->
      context "and the value is not a CacheItem", ->
        it "returns the value", ->
          cache = lcp()

          cache.set testKey, testValue
          cache.getAsync testKey
          .then (result) ->
            expect(result).toBe testValue

      context "and the value is a CacheItem", ->
        it "returns the value of the CacheItem", ->
          cache = lcp()

          cache.getAsync testKey, -> testValue
          .then (result) ->
            expect(result).toBe testValue

      context "and multiple getAsync calls pile up", ->
        it "resolves the promises in the original order (FIFO)", ->
          cache = lcp()
          fetchFunction = ->
            Promise.delay 100
            testValue

          resolved = []

          Promise .all [
            cache.getAsync testKey, fetchFunction
            .then ->
              resolved.push 1

            cache.getAsync testKey, fetchFunction
            .then ->
              resolved.push 2

            cache.getAsync testKey, fetchFunction
            .then ->
              resolved.push 3
          ]
          .then ->
            expect(resolved).toEqual [1,2,3]

    context "when the key doesn't exist", ->
      it "returns undefined", ->
        cache = lcp()
        cache.getAsync testKey
        .then (result) ->
          expect(result).toBe undefined