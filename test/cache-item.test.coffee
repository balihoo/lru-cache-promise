Promise = require "bluebird"
expect = require "expect"
CacheItem = require "../src/cache-item"

testKey = "some key"
testValue =
  stuff: "things"
testFetchFunction = ->

describe "cache-item tests", ->
  cacheItem = undefined

  before ->
    cacheItem = new CacheItem
      key: testKey
      value: testValue
      fetchFunction: testFetchFunction

  describe "constructor", ->
    it "Sets the key", ->
      expect(cacheItem.key).toBe testKey

    it "Sets the value", ->
      expect(cacheItem.value).toBe testValue

    it "Sets the fetch function", ->
      expect(cacheItem.fetchFunction).toBe testFetchFunction

    it "Sets the status to initialized", ->
      expect(cacheItem._status).toBe "initialized"

    it "Sets resolves and rejectors to empty arrays", ->
      expect(cacheItem.resolvers).toEqual []
      expect(cacheItem.rejectors).toEqual []

  describe "fetch", ->
    context "when the item has a fetchFunction", ->
      context "and its value has not been fetched", ->
        it "calls the fetchFunction", ->
          cacheItem = new CacheItem
            key: testKey
            fetchFunction: -> testValue

          cacheItem.fetch()
          .then (result) ->
            expect(result).toBe testValue

      context "and its value has been fetched", ->
        it "returns the cached value", ->
          fetchCallCount = 0

          cacheItem = new CacheItem
            key: testKey
            fetchFunction: ->
              fetchCallCount++
              testValue

          cacheItem.fetch()
          .then ->
            cacheItem.fetch()
          .then (result) ->
            expect(result)            .toBe testValue

            expect fetchCallCount
            .toBe 1

      context "and its value is being fetched", ->
        context "and the fetch is successful", ->
          it "returns a promise which resolves when the fetch operation completes", ->
            fetchCallCount = 0

            cacheItem = new CacheItem
              key: testKey
              fetchFunction: ->
                fetchCallCount++
                Promise.delay 100
                .then ->
                  testValue

            Promise.all [
              cacheItem.fetch()
              .then (result) ->
                expect(result)                .toBe testValue

              cacheItem.fetch()
              .then (result) ->
                expect(result)                .toBe testValue

              cacheItem.fetch()
              .then (result) ->
                expect(result)                .toBe testValue
            ]
            .then ->
              expect fetchCallCount
              .toBe 1

        context "and the fetch throws an error", ->
          it "returns a promise which rejects when the fetch operation fails", ->
            fetchCallCount = 0
            testError = new Error "Loud noises!"
            testFailed = new Error "Expected fetch to fail!"

            cacheItem = new CacheItem
              key: testKey
              fetchFunction: ->
                fetchCallCount++
                Promise.delay 100
                .then ->
                  throw testError

            errors = []
            keepError = (err) ->
              errors.push err

            testFailed = ->
              throw testFailed

            Promise.all [
              cacheItem.fetch()
              .then testFailed
              .catch keepError

              cacheItem.fetch()
              .then testFailed
              .catch keepError

              cacheItem.fetch()
              .then testFailed
              .catch keepError
            ]
            .then ->
              expect(fetchCallCount).toBe 1
              expect errors.length
              .toBe 3
              expect(e).toBe testError for e in errors

#      context "and status is 'fetched'", ->
#        it "returns its value", ->
#          cacheItem = new CacheItem
#            key: testKey
#            value: testValue
#            fetchFunction: testFetchFunction
#
#          cacheItem._status = "fetched"
#
#          cacheItem.fetch()
#          .then (result) ->
#            expect(result)#            .toBe testValue



    context "when the item lacks a fetchFunction", ->
      it "returns its value", ->
        cacheItem = new CacheItem
          key: testKey
          value: testValue

        cacheItem.fetch()
        .then (result) ->
          expect(result).toBe testValue