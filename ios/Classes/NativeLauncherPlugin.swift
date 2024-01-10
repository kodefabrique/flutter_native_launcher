import Flutter
import UIKit

public class NativeLauncherPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_launcher", binaryMessenger: registrar.messenger())
        let instance = NativeLauncherPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "launchAppByDeeplink" {
            if let arguments = call.arguments as? [String: Any],
               let deepLink = arguments["deeplink"] as? String {
                launchAppByDeeplink(deepLink: deepLink) { error in
                    if let error = error {
                        result(FlutterError(code: "DEEPLINK_ERROR", message: "Error opening deeplink: \(error.localizedDescription)", details: nil))
                    } else {
                        result("Deeplink opened successfully")
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func launchAppByDeeplink(deepLink: String, callback: @escaping (Error?) -> Void) {
        guard let url = URL(string: deepLink) else {
            callback(NSError(domain: "INVALID_DEEPLINK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid deeplink"]))
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    callback(nil)
                } else {
                    callback(NSError(domain: "OPEN_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error opening deeplink"]))
                }
            })
        } else {
            callback(NSError(domain: "NO_SUITABLE_APP", code: 0, userInfo: [NSLocalizedDescriptionKey: "No suitable app found"]))
        }
    }
}