import UIKit
import Flutter
import moengage_flutter
import MoEngage

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private var initialUrl : String?

    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?

  private let linkStreamHandler = LinkStreamHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window.rootViewController as! FlutterViewController
     methodChannel = FlutterMethodChannel(name: "yellowclass.com/channel", binaryMessenger: controller.binaryMessenger)
     eventChannel = FlutterEventChannel(name: "yellowclass.com/events", binaryMessenger: controller.binaryMessenger)


    methodChannel?.setMethodCallHandler({[weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "initialLink" else {
        result(FlutterMethodNotImplemented)
        return
      }
        self?.receiveInitialLink(result: result)
    })


    var sdkConfig : MOSDKConfig
        let yourAppID = "8ADXNUXU6BVIBYQDL12505AS"
        if let config = MoEngage.sharedInstance().getDefaultSDKConfiguration() {
            sdkConfig = config
            sdkConfig.moeAppID = yourAppID
        }
        else{
            sdkConfig = MOSDKConfig.init(appID: yourAppID)
        }
        // sdkConfig.appGroupID = "group.com.alphadevs.MoEngage.NotificationServices"
        sdkConfig.moeDataCenter = DATA_CENTER_01
        sdkConfig.optOutIDFATracking = true
        sdkConfig.optOutIDFVTracking = true
        sdkConfig.optOutDataTracking = true
        sdkConfig.optOutPushNotification = false
        sdkConfig.optOutInAppCampaign = true

        MOFlutterInitializer.sharedInstance.initializeWithSDKConfig(sdkConfig, andLaunchOptions: launchOptions)


    GeneratedPluginRegistrant.register(with: self)
    eventChannel?.setStreamHandler(linkStreamHandler)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    private func receiveInitialLink(result: FlutterResult){
        result(self.initialUrl)
    }

    // Universal Links
    override func application(
      _ application: UIApplication,
      continue userActivity: NSUserActivity,
      restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        eventChannel?.setStreamHandler(linkStreamHandler)
      switch userActivity.activityType {
        case NSUserActivityTypeBrowsingWeb:
          guard let url = userActivity.webpageURL else {
            return false
          }
            if(initialUrl == nil){
                initialUrl = url.absoluteString
                return true
            }
            return linkStreamHandler.handleLink(url.absoluteString)
        default: return false
      }
    }

}


class LinkStreamHandler:NSObject, FlutterStreamHandler {

  var eventSink: FlutterEventSink?

  // links will be added to this queue until the sink is ready to process them
  var queuedLinks = [String]()

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    queuedLinks.forEach({ events($0) })
    queuedLinks.removeAll()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  func handleLink(_ link: String) -> Bool {
    guard let eventSink = eventSink else {
      queuedLinks.append(link)
      return false
    }
    eventSink(link)
    return true
  }
}
