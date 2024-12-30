class CacheItemMissingException<T> {
  final T key;

  CacheItemMissingException(this.key);

  @override
  String toString() {
    return 'CacheItemMissingException: Cache item for key $key is missing.';
  }
}
