import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:moengage_flutter/inapp_campaign.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:moengage_flutter/push_campaign.dart';
import 'package:moengage_flutter/push_token.dart';

import 'base_bloc.dart';

class NotificationsBloc implements BaseBloc {
  final MoEngageFlutter moengagePlugin = MoEngageFlutter();

  //ios on received callback
  static const notificationStream =
      EventChannel('yellowclass.com/onNotificationReceived');

  //android on received callback
  static const onReceivedChannel = MethodChannel('yellowclass.com/onReceived');

  EventChannel pushTokenStream =
      Platform.isIOS ? EventChannel('yellowclass.com/push') : null;

  void initialise() {
    moengagePlugin.initialise();
    if (Platform.isIOS) {
      moengagePlugin.registerForPushNotification();
      pushTokenStream
          .receiveBroadcastStream()
          .listen((d) => onIOSPushTokenGenerated(d));
      notificationStream
          .receiveBroadcastStream()
          .listen((d) => onIOSPushNotificationReceived(d));
    }
    moengagePlugin.optOutDataTracking(true);
    moengagePlugin.enableSDKLogs();
    moengagePlugin.setUpPushTokenCallback(_onPushTokenGenerated);
    moengagePlugin.setUpPushCallbacks(_onPushClick);
    moengagePlugin.setUpInAppCallbacks(
      onInAppClick: _onInAppClick,
      onInAppShown: _onInAppShown,
      onInAppDismiss: _onInAppDismiss,
      onInAppCustomAction: _onInAppCustomAction,
      onInAppSelfHandle: _onInAppSelfHandle,
    );
    onReceivedChannel.setMethodCallHandler(androidMethodChannelHandler);
  }

  void _onPushTokenGenerated(PushToken pushToken) {
    print(
      "This is callback on push token generated from native to flutter: PushToken: " +
          pushToken.toString(),
    );
  }

  Future<dynamic> androidMethodChannelHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'onReceived':
        String trackingId =
            getTrackingIdFromAndroidPayload(methodCall.arguments.toString());
        if (trackingId != null) {
          print('DELIVERED');
        }
        return;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  void onIOSPushTokenGenerated(String iosPushToken) {
    print(
      "This is callback on push token generated from native to flutter: PushToken: " +
          iosPushToken,
    );
  }

  void onIOSPushNotificationReceived(String map) {
    Map<String, dynamic> payload = json.decode(map);
    print(
      'IOS notificaton received callback/ covers silent push in app not running state',
    );
    print(payload.toString());
    if (payload.containsKey("moengage") &&
        payload["moengage"].containsKey("silentPush") &&
        payload["moengage"]["silentPush"] == 1) {
    } else {
      if (containsIOSNotificationTrackingInPayload(payload)) {
        print('DELIVERED');
      }
    }
  }

  void _onPushClick(PushCampaign message) {
    print(
      "This is a push click callback from native to flutter. Payload " +
          message.toString(),
    );
    if (Platform.isAndroid) {
      if (message.payload.containsKey("trackingId")) {
        print('CLICKED');
      }
    }
    if (Platform.isIOS) {
      if (containsIOSNotificationTrackingInPayload(message.payload)) {
        print('CLICKED');
      }
    }
  }

  bool containsIOSNotificationTrackingInPayload(Map<String, dynamic> payload) {
    if (payload.containsKey("app_extra") &&
        payload["app_extra"].containsKey("screenData") &&
        payload["app_extra"]["screenData"].containsKey("trackingId")) {
      return true;
    }
    return false;
  }

  void _onInAppClick(InAppCampaign message) {
    print(
      "This is a inapp click callback from native to flutter. Payload " +
          message.toString(),
    );
  }

  void _onInAppShown(InAppCampaign message) {
    print(
      "This is a callback on inapp shown from native to flutter. Payload " +
          message.toString(),
    );
  }

  void _onInAppDismiss(InAppCampaign message) {
    print(
      "This is a callback on inapp dismiss from native to flutter. Payload " +
          message.toString(),
    );
  }

  void _onInAppCustomAction(InAppCampaign message) {
    print(
      "This is a callback on inapp custom action from native to flutter. Payload " +
          message.toString(),
    );
  }

  void _onInAppSelfHandle(InAppCampaign message) {
    print(
      "This is a callback on inapp self handle from native to flutter. Payload " +
          message.toString(),
    );
    moengagePlugin.selfHandledShown(message);
    moengagePlugin.selfHandledClicked(message);
    moengagePlugin.selfHandledPrimaryClicked(message);
    moengagePlugin.selfHandledDismissed(message);
  }

  String getTrackingIdFromAndroidPayload(String rawPayload) {
    List<String> kvPairs = rawPayload.split(',');
    for (int i = 0; i < kvPairs.length; i++) {
      if (kvPairs[i].contains("trackingId")) {
        return kvPairs[i].split(':')[1].trim();
      }
    }
    return null;
  }

  @override
  void dispose() {}
}

final NotificationsBloc notificationsBloc = NotificationsBloc();
