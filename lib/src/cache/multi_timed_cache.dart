import 'package:vit_cache/src/data/models/cached_item.dart';
import 'package:vit_cache/src/errors/cache_item_missing.dart';

import 'timed_cache_model.dart';

/// A cache model that supports multiple keys and values with a time-to-live (ttl).
///
/// The ttl is applied to each individual item in the cache separetly.
class MultiTimedCache<K, V> extends TimedCacheModel {
  /// Internal cache storage.
  final Map<K, CachedItem<V>> _internalCache = {};

  /// Private function to fetch a single value.
  final Future<V> Function(K key) _fetch;

  /// Private function to fetch multiple values.
  final Future<Map<K, V>> Function(Iterable<K> keys) _fetchMany;

  final Duration _ttl;

  /// Creates a new [MultiTimedCache] with the given [ttl] and fetch functions.
  MultiTimedCache({
    required Duration ttl,
    required Future<V> Function(K key) fetch,
    required Future<Map<K, V>> Function(Iterable<K> keys) fetchMany,
  })  : _fetch = fetch,
        _fetchMany = fetchMany,
        _ttl = ttl;

  @override
  Duration get ttl => _ttl;

  /// Provides access to the internal cache.
  Map<K, CachedItem<V>> get cache => _internalCache;

  /// Returns a simplified version of the [cache] without metadata.
  Map<K, V> get simpleCache {
    return {for (var entry in cache.entries) entry.key: entry.value.value};
  }

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
    await ensureCached(keys);

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
  Future<void> ensureCached(Iterable<K> keys) async {
    // Getting keys that did not expire.
    var validKeys = <K>{};

    var entries = _internalCache.entries.toList();
    for (var MapEntry(key: key, value: value) in entries) {
      if (didExpire(value.createdAt)) {
        // No need to maintain expired items
        _internalCache.remove(key);
        continue;
      }
      validKeys.add(key);
    }

    // Getting keys that will need to be fetched
    var keysToFetch = <K>{};
    for (var key in keys) {
      if (validKeys.contains(key)) {
        // Exclude keys that are already cached
        continue;
      }
      keysToFetch.add(key);
    }
    if (keysToFetch.isEmpty) return;

    // Fetching
    var foundValues = await _fetchMany(keysToFetch);

    // Saving fetched values
    for (var MapEntry(key: key, value: value) in foundValues.entries) {
      _internalCache[key] = CachedItem(value);
    }
  }

  /// Saves a value for the given [key] in the cache.
  void save(K key, V value) => _internalCache[key] = CachedItem(value);

  /// Invalidates the cache for the given [key].
  void invalidate(K key) => _internalCache.remove(key);

  /// Clears the entire cache.
  void clear() => _internalCache.clear();

  /// Removes expired items from the internal cache to manage memory and maintain data integrity.
  ///
  /// Proactively cleans up stale entries that have exceeded their time-to-live (TTL),
  /// preventing unnecessary memory usage and potential issues with outdated data.
  void clearExpired() {
    var entries = _internalCache.entries.toList();
    for (var MapEntry(key: key, value: value) in entries) {
      if (didExpire(value.createdAt)) {
        _internalCache.remove(key);
      }
    }
  }

  /// Fetches a value for the given [key] and sets it in the cache.
  Future<V> _fetchAndSet(K key) async {
    var item = await _fetch(key);
    _internalCache[key] = CachedItem(item);
    return item;
  }
}
