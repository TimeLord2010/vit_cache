import 'package:test/test.dart';
import 'package:vit_cache/vit_cache.dart';

void main() {
  test('multi timed cache model ...', () async {
    var cache = MultiTimedCache<int, int>(
      ttl: Duration(milliseconds: 200),
      fetch: (int key) async {
        return key;
      },
      fetchMany: (Iterable<int> keys) async {
        return {
          for (var key in keys) key: 0,
        };
      },
    );

    await cache.ensureCached({0, 1, 2});

    expect(cache.cache.length, 3);

    await Future.delayed(Duration(milliseconds: 500));

    cache.clearExpired();

    expect(cache.cache.length, 0);

    await cache.ensureCached({2});

    expect(cache.cache.length, 1);
  });
}
