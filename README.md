A Dart package for caching single values and multiple key-value pairs with a time-to-live (TTL) mechanism. This package helps in reducing redundant network calls or expensive operations by caching the results for a specified duration.

## Features

- Cache a single value with a TTL.
- Cache multiple key-value pairs with individual TTLs.
- Automatically fetch and update the cache when it expires.
- Manually update or clear the cache.

## Getting started

To start using this package, add it to your `pubspec.yaml`:

```bash
flutter pub add vit_cache
```

## Usage

### Singular Cache

Here is an example of using `SingularCache` to fetch a configuration from an API:

```dart
import 'package:vit_cache/vit_cache.dart';

class UserInfoCache extends SingularCache<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> fetch() async {
    // Simulate a network call to fetch configuration
    await Future.delayed(Duration(seconds: 2));
    return {
        'name': 'Dave',
        'auth_token': 'xxxxx'
    };
  }

  @override
  Duration get ttl => Duration(seconds: 10);
}

void main() async {
  var configCache = UserInfoCache();

  // Fetch and cache
  var info = await configCache.get();
  print('Info: $info');

  // Cache hit
  var info = await configCache.get();
  print('Info: $info');

  // Update the cached value manually.
  configCache.update({
    'name': 'Dave',
    'auth_token': 'xxxxx'
  });

  // Clear the cache
  configCache.clear();
}
```

### Multi Cache

Here is an example of using `MultiTimedCacheModel` to fetch multiple configurations from an API:

```dart
import 'package:vit_cache/vit_cache.dart';

class ConfigCache extends MultiTimedCacheModel<String, Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> fetch(String key) async {
    // Simulate a network call to fetch configuration
    await Future.delayed(Duration(seconds: 2));
    return {'apiUrl': 'https://api.example.com/$key', 'timeout': 5000};
  }

  @override
  Future<Map<String, Map<String, dynamic>>> fetchMany(Iterable<String> keys) async {
    // Simulate a network call to fetch multiple configurations
    await Future.delayed(Duration(seconds: 2));
    return {for (var key in keys) key: {'apiUrl': 'https://api.example.com/$key', 'timeout': 5000}};
  }

  @override
  Duration get ttl => Duration(seconds: 10);
}

void main() async {
  var configCache = ConfigCache();

  // Fetch and cache a single configuration
  var config = await configCache.get('service1');
  print('Config for service1: $config');

  // Fetch and cache multiple configurations
  await configCache.setMany(['service1', 'service2']);
  var config1 = await configCache.get('service1');
  var config2 = await configCache.get('service2');
  print('Config for service1: $config1');
  print('Config for service2: $config2');

  // Clear the cache for a specific key
  configCache.invalidate('service1');

  // Clear the entire cache
  configCache.clear();
}
```

## Methods

### Singular Cache

| Method               | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `Future<T> fetch()`  | Abstract method to fetch the value to cache. Must be implemented by subclasses. |
| `Future<T> get()`    | Retrieves the cached value or fetches it if not present or expired.         |
| `void update(T value)` | Updates the cached value with the given value.                             |
| `void updateIfCached(T Function(T oldValue) func)` | Updates the cached value using the provided function if it is cached and not expired. |
| `void clear()`       | Clears the cached value.                                                    |

### Multi Cache

| Method               | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `Future<V> fetch(K key)`  | Abstract method to fetch the value for a given key. Must be implemented by subclasses. |
| `Future<Map<K, V>> fetchMany(Iterable<K> keys)` | Abstract method to fetch multiple values for given keys. Must be implemented by subclasses. |
| `Future<V> get(K key)`    | Retrieves the cached value for a given key or fetches it if not present or expired.         |
| `Future<Map<K, V>> getMany(Iterable<K> keys)` | Retries the cached values for the given key set. Non-existent or expired values are fetched.  |
| `Future<void> setMany(Iterable<K> keys)` | Fetches and caches multiple values for given keys.                             |
| `void save(K key, V value)` | Saves a value for a given key in the cache.                             |
| `void invalidate(K key)` | Invalidates the cache for a given key.                             |
| `void clear()`       | Clears the entire cache.                                                    |
| `void clearExpired()` | Clears expired items from the cache.                                                    |

## Additional information

For more information, visit the [documentation](https://dart.dev/tools/pub/writing-package-pages). Contributions are welcome. Please file issues on the [GitHub repository](https://github.com/your-repo/vit_cache).
