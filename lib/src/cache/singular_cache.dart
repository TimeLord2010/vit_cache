import 'timed_cache_model.dart';

/// A cache model for a single value with a time-to-live (ttl).
///
/// This class provides methods to fetch, update, and clear the cached value.
class SingularCache<T> extends TimedCacheModel {
  /// Internal cache storage for the single value.
  T? _internalCache;

  /// Future representing an ongoing fetch operation.
  Future<T>? _cacheFuture;

  /// The time when the value was last fetched.
  DateTime? _lastFetch;

  /// Private function to fetch the value.
  final Future<T> Function() _fetch;

  /// Creates a new [SingularCache] with the given [ttl] and [fetch] function.
  SingularCache({
    required Duration ttl,
    required Future<T> Function() fetch,
  })  : _fetch = fetch,
        _ttl = ttl;

  final Duration _ttl;

  @override
  Duration get ttl => _ttl;

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
      var value = await _fetch();
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
