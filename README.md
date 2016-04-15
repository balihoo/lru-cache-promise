# lru-cache-promise
lru-cache with promises

This library wraps Isaac Z. Schlueter's [lru-cache](https://github.com/isaacs/node-lru-cache) and adds a getAsync function.

## Usage:
```javascript
var cache = require("lru-cache-promise")();

var fetchFunction = function(key) {
  /* Do something async here to fetch the value */
};

cache.getAsync("some key", fetchFunction)
.then(function(value) { console.log(value) });
```

getAsync returns an A+ (specifically [bluebird](https://github.com/petkaantonov/bluebird)) promise.
* If the value has already been cached, the promise will resolve immediately
* If not, fetchFunction will be called with the requested key.  fetchFunction must return either a concrete value or a promise.

getAsync ensures only one call to fetchFunction for a given key,
allowing the calling code to be make many concurrent calls for the same key
without negatively impacting the system from which the values are fetched.

