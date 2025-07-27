class CachedItem<T> {
  /// The cached value.
  final T value;

  /// The time when the item was created.
  final DateTime createdAt = DateTime.now();

  CachedItem(this.value);
}
