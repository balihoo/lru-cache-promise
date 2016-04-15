# lru-cache-promise
lru-cache with promises

This library wraps Isaac Z. Schlueter's [lru-cache](https://github.com/isaacs/node-lru-cache) and adds a getAsync function.

## Usage:
```javascript
var Promise = require("bluebird");
var cache = require("lru-cache-promise")();

var key = "some_key";
var values = {
  some_key: "some value",
  another_key: "another value"
};

var fetchFunction = function(key) {
  /* Do something async here to fetch the value */
};

cache.getAsync("key", fetchFunction);
```

getAsync returns an A+ (specifically bluebird) promise.
* If the value has already been cached, the promise will resolve immediately
* If not, the fetchFunction will be called with the requested key.  fetchFunction must return either a concrete value or a promise.

getAsync ensures only one concurrent call to fetchFunction occurs for a given key,
allowing the calling code to be highly concurrent.

