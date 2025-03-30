import UIKit
import Flutter
import zpdk


// chanel Init to handle Channel Flutter
enum ChannelName {
  static let channelPayOrder = "flutter.native/channelPayOrder"
  static let eventPayOrder = "flutter.native/eventPayOrder"
}

// methods define to handle in channel
enum MethodNames {
    static let methodPayOrder = "payOrder"
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  //Call this function again whenever you want to reinitialize ZPDK to allow payment with another app_id
  //The uriScheme is the same as merchant-deeplink configured in Info.plist above
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ZalopaySDK.sharedInstance()?.initWithAppId(<appid>, uriScheme: "<merchant-deeplink>", environment: <ZPZPIEnvironment>)
    return true
  }

  //Call ZPDK to handle the data exchange between Zalopay and the app. Call this function because ZPDK is currently checking whether the sourceApplication is Zalopay App or not.
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return ZalopaySDK.sharedInstance().application(app, open: url, sourceApplication:"vn.com.vng.Zalopay", annotation: nil)
  }

  func paymentDidSucceeded(_ transactionId: String!, zpTranstoken: String!, appTransId: String!) {
        //Handle Success
        guard let eventSink = eventSink else {
          return
        }
        eventSink(["errorCode": PAYMENTCOMPLETE, "zpTranstoken": zpTranstoken ?? "", "transactionId": transactionId ?? "", "appTransId": appTransId ?? ""])
    }
    func paymentDidCanceled(_ zpTranstoken: String!, appTransId: String!) {
        //Handle Canceled
        guard let eventSink = eventSink else {
          return
        }
        eventSink(["errorCode": PAYMENTCANCELED, "zpTranstoken": zpTranstoken ?? "", "appTransId": appTransId ?? ""])
    }
    func paymentDidError(_ errorCode: ZPPaymentErrorCode, zpTranstoken: String!, appTransId: String!) {
        guard let eventSink = eventSink else {
          return
        }
        eventSink(["errorCode": PAYMENTERROR, "zpTranstoken": zpTranstoken ?? "", "appTransId": appTransId ?? ""])
    }
    func installSandbox(){
        let alert = UIAlertController(title: "Info", message: "Please install ZaloPay", preferredStyle: UIAlertController.Style.alert)
        let installLink = "https://sandbox.zalopay.com.vn/static/ps_res_2019/ios/enterprise/sandboxmer/install.html"
        let controller = window.rootViewController as? FlutterViewController
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in

        }
        let installAction = UIAlertAction(title: "Install App", style: .default) { (action) in
            guard let url = URL(string: installLink) else {
                return //be safe
            }
            //


            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(installAction)
        controller?.present(alert, animated: true, completion: nil)
    }

    func installProduction(){
        let alert = UIAlertController(title: "Info", message: "Please install ZaloPay", preferredStyle: UIAlertController.Style.alert)
        let controller = window.rootViewController as? FlutterViewController
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in

        }
        let installAction = UIAlertAction(title: "Install App", style: .default) { (action) in
            ZaloPaySDK.sharedInstance()?.navigateToZaloStore()
        }
        alert.addAction(cancelAction)
        alert.addAction(installAction)
        controller?.present(alert, animated: true, completion: nil)
    }

    // func implement with FlutterStreamHandler
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
     }

    // func implement with FlutterStreamHandler
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
