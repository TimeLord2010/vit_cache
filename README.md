A Dart package for caching single values and multiple key-value pairs with a time-to-live (TTL) mechanism. This package helps in reducing redundant network calls or expensive operations by caching the results for a specified duration.

## Features

- Cache a single value with a TTL using constructor-based configuration.
- Cache multiple key-value pairs with individual TTLs.
- Automatically fetch and update the cache when it expires.
- Manually update or clear the cache.
- Memory management with expired item cleanup.

## Getting started

To start using this package, add it to your `pubspec.yaml`:

```bash
flutter pub add vit_cache
```

## Usage

### Singular Cache

Here is an example of using `SingularCache` to fetch user information from an API:

```dart
import 'package:vit_cache/vit_cache.dart';

void main() async {
  // Create a cache with a fetch function
  var userInfoCache = SingularCache<Map<String, dynamic>>(
    ttl: Duration(seconds: 10),
    fetch: () async {
      // Simulate a network call to fetch user info
      await Future.delayed(Duration(seconds: 2));
      return {'name': 'Dave', 'auth_token': 'xxxxx'};
    },
  );

  // Fetch and cache user info
  var info = await userInfoCache.get();
  print('User Info: $info');

  // Cache hit - no network call needed
  info = await userInfoCache.get();
  print('User Info: $info');

  // Update the cached value manually
  userInfoCache.update({'name': 'Dave', 'auth_token': 'yyyyy'});

  // Clear the cache
  userInfoCache.clear();
}
```

### Multi Cache

Here is an example of using `MultiTimedCache` to fetch multiple configurations from an API:

```dart
import 'package:vit_cache/vit_cache.dart';

void main() async {
  // Create a multi-key cache with a fetch function
  var configCache = MultiTimedCache<String, Map<String, dynamic>>(
    ttl: Duration(seconds: 10),
    fetchMany: (keys) async {
      // Simulate a network call to fetch multiple configurations
      await Future.delayed(Duration(seconds: 2));
      return {
        for (var key in keys)
          key: {'apiUrl': 'https://api.example.com/$key', 'timeout': 5000}
      };
    },
  );

  // Fetch and cache a single configuration
  var config = await configCache.get('service1');
  print('Config for service1: $config');

  // Fetch and cache multiple configurations at once
  await configCache.ensureCached(['service1', 'service2', 'service3']);

  // Get multiple cached values
  var configs = await configCache.getMany(['service1', 'service2']);
  print('Configs: $configs');

  // Save a value directly to cache
  configCache.save('service4', {'apiUrl': 'https://api.example.com/service4', 'timeout': 3000});

  // Clear the cache for a specific key
  configCache.invalidate('service1');

  // Clear expired items only
  configCache.clearExpired();

  // Clear the entire cache
  configCache.clear();
}
```

## Methods

### SingularCache

| Method               | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `Future<T> get()`    | Retrieves the cached value or fetches it if not present or expired.         |
| `void update(T value)` | Updates the cached value with the given value and resets the TTL.                             |
| `void updateIfCached(T Function(T oldValue) func)` | Updates the cached value using the provided function if it is cached and not expired. |
| `void clear()`       | Clears the cached value.                                                    |

### MultiTimedCache

| Method               | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `Future<V> get(K key)`    | Retrieves the cached value for a given key or fetches it if not present or expired.         |
| `Future<Map<K, V>> getMany(Iterable<K> keys, {bool assumeAllPresent = false})` | Retrieves cached values for the given key set. Non-existent or expired values are fetched. If `assumeAllPresent` is true, throws an exception if any key is missing.  |
| `Future<void> ensureCached(Iterable<K> keys)` | Fetches all keys that are not already cached or have expired.                             |
| `void save(K key, V value)` | Saves a value for a given key in the cache.                             |
| `void invalidate(K key)` | Invalidates the cache for a given key.                             |
| `void clear()`       | Clears the entire cache.                                                    |
| `void clearExpired()` | Removes expired items from the cache to manage memory and maintain data integrity.                                                    |
| `Map<K, CachedItem<V>> get cache` | Provides access to the internal cache with metadata.                                                    |
| `Map<K, V> get simpleCache` | Returns a simplified version of the cache without metadata.                                                    |

## Additional information

For more information, visit the [documentation](https://dart.dev/tools/pub/writing-package-pages). Contributions are welcome. Please file issues on the [GitHub repository](https://github.com/your-repo/vit_cache).
