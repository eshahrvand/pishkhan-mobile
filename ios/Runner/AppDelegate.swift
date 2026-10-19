import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let linksChannel = FlutterMethodChannel(
      name: "pishkhan/external_links",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    linksChannel.setMethodCallHandler { call, result in
      guard call.method == "openRegistry" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let url = URL(string: "https://amlak.mrud.ir") else {
        result(FlutterError(code: "browser-unavailable", message: nil, details: nil))
        return
      }
      UIApplication.shared.open(url) { opened in
        result(opened ? nil : FlutterError(code: "browser-unavailable", message: nil, details: nil))
      }
    }
    let channel = FlutterMethodChannel(
      name: "pishkhan/platform_share",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "shareText" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let text = call.arguments as? String,
        var presenter = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene })
          .flatMap({ $0.windows })
          .first(where: { $0.isKeyWindow })?.rootViewController
      else {
        result(FlutterError(code: "share-unavailable", message: nil, details: nil))
        return
      }
      while let presented = presenter.presentedViewController {
        presenter = presented
      }
      let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
      if let popover = controller.popoverPresentationController {
        popover.sourceView = presenter.view
        popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
        popover.permittedArrowDirections = []
      }
      presenter.present(controller, animated: true) { result(nil) }
    }
  }
}
