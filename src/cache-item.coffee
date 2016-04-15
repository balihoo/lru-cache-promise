Promise = require 'bluebird'

status =
  initialized: "initialized"
  fetching: "fetching"
  fetched: "fetched"
  fetchFailed: "fetch failed"

module.exports = class CacheItem
  constructor: (opts) ->
    @key = opts.key
    @value = opts.value
    @_status = status.initialized
    @fetchFunction = opts.fetchFunction
    @resolvers = []
    @rejectors = []

  fetch: ->
    Promise.try =>
      if @_status is status.fetched or not @fetchFunction
        # Return the current value
        return @value

      if @_status is status.fetching
        # Add a promise to the list of promises awaiting fetch completion
        p = new Promise (resolve, reject) =>
          @resolvers.push resolve
          @rejectors.push reject

        return p

      # Call the fetch function
      @_status = status.fetching

      Promise.resolve @fetchFunction @key
      .then (value) =>
        @value = value
        @_status = status.fetched

        r value for r in @resolvers

        value

      .catch (err) =>
        @_status = status.fetchFailed

        r err for r in @rejectors

        throw err