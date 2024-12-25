/// An interface that enforces a time-to-live (ttl) for cached data.
/// Implementations can use [didExpire] to determine if the data is still valid.
abstract class TimedCacheModel {
  /// The duration that determines how long the cache is valid.
  Duration get ttl;

  /// Method to check if a cache expired by date.
  /// Checks if the cache has expired based on the provided [lastCache].
  bool didExpire(DateTime? lastCache) {
    if (lastCache == null) return true;
    var dt = DateTime.now();
    return dt.difference(lastCache).inSeconds > ttl.inSeconds;
  }
}
