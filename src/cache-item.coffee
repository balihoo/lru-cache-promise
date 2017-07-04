Promise = require 'bluebird'

STATUS =
  initialized: "initialized"
  fetching: "fetching"
  fetched: "fetched"
  fetchFailed: "fetch failed"

module.exports = class CacheItem
  constructor: (opts) ->
    @key = opts.key
    @value = opts.value
    @fetchFunction = opts.fetchFunction
    @init()

  init: (status = STATUS.initialized) ->
    @_status = status
    @resolvers = []
    @rejectors = []

  fetch: ->
    Promise.try =>
      @init() if @_status is STATUS.fetchFailed

      if @_status is STATUS.fetched or not @fetchFunction
        # Return the current value
        return @value

      # Add a promise to the list of promises awaiting fetch completion
      p = new Promise (resolve, reject) =>
        @resolvers.push resolve
        @rejectors.push reject

      if @_status is STATUS.initialized
        # Call the fetch function
        @_status = STATUS.fetching

        Promise.try =>
          @fetchFunction @key
        .then (value) =>
          @value = value
          @_status = STATUS.fetched

          r value for r in @resolvers

        .catch (err) =>
          @_status = STATUS.fetchFailed

          r err for r in @rejectors

        .finally =>
          # Clear the old resolvers and rejectors as a matter of good housekeeping
          @init @_status

      return p