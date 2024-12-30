import 'package:vit_cache/src/errors/cache_item_missing.dart';

import 'timed_cache_model.dart';

/// A cache model that supports multiple keys and values with a time-to-live (ttl).
///
/// The ttl is applied to each individual item in the cache separetly.
abstract class MultiTimedCacheModel<K, V> extends TimedCacheModel {
  /// Internal cache storage.
  final Map<K, MultiCacheItem<V>> _internalCache = {};

  /// Provides access to the internal cache.
  Map<K, MultiCacheItem<V>> get cache => _internalCache;

  /// Fetches a value for the given [key].
  ///
  /// This method does not have cache and should not be used outside of the cache model.
  Future<V> fetch(K key);

  /// Fetches values for the given [keys].
  ///
  /// This method does not have cache and should not be used outside of the cache model.
  Future<Map<K, V>> fetchMany(Iterable<K> keys);

  /// Retrieves a value for the given [key] from the cache or fetches it if not present or expired.
  Future<V> get(K key) async {
    var cachedItem = _internalCache[key];
    if (cachedItem == null) {
      return _fetchAndSet(key);
    }

    if (didExpire(cachedItem.createdAt)) {
      return _fetchAndSet(key);
    }

    return cachedItem.value;
  }

  /// Retrieves values for the given [keys] from the cache or fetches them if
  /// not present or expired.
  ///
  /// If [assumeAllPresent] is set to `true`, the method will throw an
  /// [CacheItemMissingException] if any of the keys are not found in the cache.
  Future<Map<K, V>> getMany(
    Iterable<K> keys, {
    bool assumeAllPresent = false,
  }) async {
    await setMany(keys);

    Map<K, V> result = {};

    for (var key in keys) {
      var cachedItem = _internalCache[key];
      if (cachedItem == null) {
        if (assumeAllPresent) {
          throw CacheItemMissingException(key);
        }
        continue;
      }
      result[key] = cachedItem.value;
    }

    return result;
  }

  /// Fetches all keys that are not already cached.
  Future<void> setMany(Iterable<K> keys) async {
    var validKeys = <K>{};
    for (var MapEntry(key: key, value: value) in _internalCache.entries) {
      if (didExpire(value.createdAt)) {
        _internalCache.remove(key);
        continue;
      }
      validKeys.add(key);
    }

    var keysToFetch = <K>{};
    for (var key in keys) {
      if (validKeys.contains(key)) {
        continue;
      }
      keysToFetch.add(key);
    }

    if (keysToFetch.isEmpty) {
      return;
    }

    var foundValues = await fetchMany(keysToFetch);
    for (var MapEntry(key: key, value: value) in foundValues.entries) {
      _internalCache[key] = MultiCacheItem(value);
    }
  }

  /// Saves a value for the given [key] in the cache.
  void save(K key, V value) => _internalCache[key] = MultiCacheItem(value);

  /// Fetches a value for the given [key] and sets it in the cache.
  Future<V> _fetchAndSet(K key) async {
    var item = await fetch(key);
    _internalCache[key] = MultiCacheItem(item);
    return item;
  }

  /// Invalidates the cache for the given [key].
  void invalidate(K key) => _internalCache.remove(key);

  /// Clears the entire cache.
  void clear() => _internalCache.clear();

  void clearExpired() {
    for (var MapEntry(key: key, value: value) in _internalCache.entries) {
      if (didExpire(value.createdAt)) {
        _internalCache.remove(key);
      }
    }
  }
}

/// Represents a cached item with its value and creation time.
class MultiCacheItem<T> {
  /// The cached value.
  final T value;

  /// The time when the item was created.
  final DateTime createdAt = DateTime.now();

  MultiCacheItem(this.value);
}
