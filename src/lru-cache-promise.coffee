Promise = require 'bluebird'
lruCache = require 'lru-cache'
CacheItem = require './cache-item'

module.exports = (opts) ->
  cache = lruCache opts

  cache.getAsync = (key, fetchFunction) ->
    item = cache.get key

    if item is undefined and fetchFunction
      # Create a new cache item
      item = new CacheItem
        key: key
        fetchFunction: fetchFunction

      cache.set key, item

    return Promise.resolve item unless item instanceof CacheItem

    item.fetch()

  cache