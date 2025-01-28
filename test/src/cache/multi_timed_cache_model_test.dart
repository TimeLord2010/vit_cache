import 'package:test/test.dart';
import 'package:vit_cache/vit_cache.dart';

class _MockCache extends MultiTimedCacheModel<int, int> {
  @override
  Future<int> fetch(int key) async {
    return key;
  }

  @override
  Future<Map<int, int>> fetchMany(Iterable<int> keys) async {
    return {
      for (var key in keys) key: 0,
    };
  }

  @override
  Duration get ttl => Duration(milliseconds: 200);
}

void main() {
  test('multi timed cache model ...', () async {
    var cache = _MockCache();

    await cache.setMany({0, 1, 2});

    expect(cache.cache.length, 3);

    await Future.delayed(Duration(milliseconds: 500));

    cache.clearExpired();

    expect(cache.cache.length, 0);

    await cache.setMany({2});

    expect(cache.cache.length, 1);
  });
}
