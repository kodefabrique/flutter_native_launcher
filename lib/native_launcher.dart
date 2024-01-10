import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_launcher_platform_interface.dart';

/// An implementation of [NativeLauncherPlatform] that uses method channels.
class NativeLauncher extends NativeLauncherPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_launcher');

  Future<String?> launchAppByDeeplink({
    required String deeplink,
    required String? packageName,
    required Function(Exception) errorCallback,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<String>(
        'launchAppByDeeplink',
        {
          "deeplink": deeplink,
          "packageName": packageName,
        },
      );
      return result;
    } on PlatformException catch (e) {
      errorCallback.call(e);
      return null;
    }
  }
}
