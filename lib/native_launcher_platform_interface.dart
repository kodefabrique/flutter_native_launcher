import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_launcher.dart';

abstract class NativeLauncherPlatform extends PlatformInterface {
  /// Constructs a NativeLauncherPlatform.
  NativeLauncherPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeLauncherPlatform _instance = NativeLauncher();

  /// The default instance of [NativeLauncherPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeLauncher].
  static NativeLauncherPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeLauncherPlatform] when
  /// they register themselves.
  static set instance(NativeLauncherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
