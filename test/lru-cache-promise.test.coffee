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

    context "when the key doesn't exist", ->
      it "returns undefined", ->
        cache = lcp()
        cache.getAsync testKey
        .then (result) ->
          expect(result).toBe undefined