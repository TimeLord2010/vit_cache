import 'timed_cache_model.dart';

/// A cache model for a single value with a time-to-live (ttl).
///
/// This class provides methods to fetch, update, and clear the cached value.
abstract class SingularCache<T> extends TimedCacheModel {
  /// Internal cache storage for the single value.
  T? _internalCache;

  /// Future representing an ongoing fetch operation.
  Future<T>? _cacheFuture;

  /// The time when the value was last fetched.
  DateTime? _lastFetch;

  /// Fetches the value to cache.
  ///
  /// Always performs the slow operation that is to get the underlying value.
  ///
  /// This method is intended for internal use of [SingularCache].
  Future<T> fetch();

  /// Retrieves the cached value or fetches it if not present or expired.
  Future<T> get() async {
    var cache = _internalCache;
    if (cache == null) {
      return await _fetchAndSaveOnce();
    }

    if (didExpire(_lastFetch)) {
      return await _fetchAndSaveOnce();
    }

    return cache;
  }

  /// Prevents [_fetchAndSave] from creating parallel futures by calling [fetch] multiple times.
  ///
  /// This can happen if the [get] method is called again when the previous call of [get] did not
  /// finish yet.
  Future<T> _fetchAndSaveOnce() {
    var future = _cacheFuture;
    if (future != null) {
      return future;
    }

    future = _cacheFuture = _fetchAndSave();
    return future;
  }

  /// Fetches the value and saves it in the cache.
  Future<T> _fetchAndSave() async {
    try {
      _internalCache = null;
      var value = await fetch();
      _internalCache = value;
      _lastFetch = DateTime.now();
      return value;
    } finally {
      _cacheFuture = null;
    }
  }

  /// Updates the cached value with the given [value].
  void update(T value) {
    _internalCache = value;
    _lastFetch = DateTime.now();
  }

  /// Updates the cached value using the provided function [func] if it is cached and not expired.
  void updateIfCached(T Function(T oldValue) func) {
    var internalValue = _internalCache;
    if (internalValue == null) {
      return;
    }

    if (didExpire(_lastFetch)) {
      return;
    }

    internalValue = func(internalValue);
  }

  /// Clears the cached value.
  void clear() {
    this._internalCache = null;
  }
}
