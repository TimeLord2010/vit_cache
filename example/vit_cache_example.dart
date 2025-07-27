import 'package:vit_cache/vit_cache.dart';

void main() async {
  // Create a cache with a fetch function
  var userInfoCache = SingularCache<Map<String, dynamic>>(
    ttl: Duration(seconds: 10),
    fetch: () async {
      // Simulate a network call to fetch user info
      await Future.delayed(Duration(seconds: 2));
      return {'name': 'Dave', 'auth_token': 'xxxxx'};
    },
  );

  // Fetch and cache user info
  var info = await userInfoCache.get();
  print('User Info: $info');

  // Cache hit
  info = await userInfoCache.get();
  print('User Info: $info');

  // Update the cached value manually
  userInfoCache.update({'name': 'Dave', 'auth_token': 'xxxxx'});

  // Clear the cache
  userInfoCache.clear();
}
