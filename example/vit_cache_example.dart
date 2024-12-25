import 'package:vit_cache/vit_cache.dart';

class UserInfoCache extends SingularCache<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> fetch() async {
    // Simulate a network call to fetch user info
    await Future.delayed(Duration(seconds: 2));
    return {'name': 'Dave', 'auth_token': 'xxxxx'};
  }

  @override
  Duration get ttl => Duration(seconds: 10);
}

void main() async {
  var userInfoCache = UserInfoCache();

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
