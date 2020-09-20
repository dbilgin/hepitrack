import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfig {
  static Future<RemoteConfig> setupRemoteConfig() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: false));
    var connectivityResult = await (Connectivity().checkConnectivity());
    try {
      if (connectivityResult != ConnectivityResult.none) {
        // default expiration is 12 hours
        await remoteConfig.fetch();
      }
    } catch (error) {}
    await remoteConfig.activateFetched();
    return remoteConfig;
  }
}
