## 2.1.1

- Updated documentation.

## 2.1.0

**Improvements:**
- Removed redundant `fetch` parameter from `MultiTimedCache` constructor
- Simplified API by using only `fetchMany` function for all fetch operations

**Migration Guide:**
- Remove the `fetch` parameter from `MultiTimedCache` constructor calls
- Ensure your `fetchMany` function can handle single-key requests (it should already work as-is)

## 2.0.0

**BREAKING CHANGES:**
- Converted `SingularCache` from abstract class to concrete class with constructor parameters
- Converted `MultiTimedCacheModel` to `MultiTimedCache` concrete class with constructor parameters
- Renamed `MultiTimedCacheModel.setMany()` to `MultiTimedCache.ensureCached()`
- Replaced internal `MultiCacheItem` with generic `CachedItem` class
- Added `MultiTimedCache.simpleCache` getter for accessing cache without metadata
- Updated API to use function parameters instead of method overrides for fetch operations

**New Features:**
- Added `CachedItem<T>` model class for better cache item representation
- Improved constructor-based API for easier usage without inheritance

**Migration Guide:**
- Replace `class MyCache extends SingularCache<T>` with `SingularCache<T>(ttl: duration, fetch: () async => ...)`
- Replace `class MyCache extends MultiTimedCacheModel<K, V>` with `MultiTimedCache<K, V>(ttl: duration, fetch: (key) async => ..., fetchMany: (keys) async => ...)`
- Replace `setMany()` calls with `ensureCached()`

## 1.1.1

- Fixed ttl calculating when dealing with milliseconds.
- Fixed problems while dealing with expired items in "clearExpired" and "setMany" of `MultiTimedCacheModel`.

## 1.1.0

- Added "assumeAllPresent" option to `MultiTimesCacheModel.getMany`.

## 1.0.0

- Initial version.
