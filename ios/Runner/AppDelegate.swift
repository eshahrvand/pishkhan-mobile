import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, UIDocumentPickerDelegate {
  private var documentResult: FlutterResult?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let documents = FlutterMethodChannel(name: "pishkhan/document_picker",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())
    documents.setMethodCallHandler { [weak self] call, result in
      guard call.method == "pickSpreadsheet" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let self = self, self.documentResult == nil,
        var presenter = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows })
          .first(where: { $0.isKeyWindow })?.rootViewController else {
        result(FlutterError(code: "picker-unavailable", message: nil, details: nil))
        return
      }
      while let presented = presenter.presentedViewController { presenter = presented }
      self.documentResult = result
      let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "xls") ?? .spreadsheet], asCopy: true)
      picker.delegate = self
      picker.allowsMultipleSelection = false
      presenter.present(picker, animated: true)
    }
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
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    let result = documentResult
    documentResult = nil
    result?(nil)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    let result = documentResult
    documentResult = nil
    guard let url = urls.first else { result?(nil); return }
    let access = url.startAccessingSecurityScopedResource()
    defer {
      if access { url.stopAccessingSecurityScopedResource() }
      // asCopy creates a temporary picker copy; do not retain financial files on disk.
      try? FileManager.default.removeItem(at: url)
    }
    do {
      let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
      guard size > 0 && size <= 102400 else {
        result?(FlutterError(code: "file-invalid", message: nil, details: nil)); return
      }
      let data = try Data(contentsOf: url)
      result?(["name": url.lastPathComponent, "bytes": FlutterStandardTypedData(bytes: data)])
    } catch {
      result?(FlutterError(code: "file-unavailable", message: nil, details: nil))
    }
  }

}
