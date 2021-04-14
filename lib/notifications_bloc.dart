import 'dart:io';

import 'package:moengage_flutter/inapp_campaign.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:moengage_flutter/push_campaign.dart';
import 'package:moengage_flutter/push_token.dart';

import 'package:moengage_test/base_bloc.dart';

class NotificationsBloc implements BaseBloc {
  final MoEngageFlutter moengagePlugin = MoEngageFlutter();

  void initialise() {
    moengagePlugin.initialise();
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
    if (Platform.isIOS) {
      moengagePlugin.registerForPushNotification();
    }
  }

  void _onPushTokenGenerated(PushToken pushToken) {
    print(
      "This is callback on push token generated from native to flutter: PushToken: " +
          pushToken.toString(),
    );
    // this os not getting triggered in ios, working fine in android after token generation
  }

  void _onPushClick(PushCampaign message) {
    print(
      "This is a push click callback from native to flutter. Payload " +
          message.toString(),
    );
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

  @override
  void dispose() {}
}

final NotificationsBloc notificationsBloc = NotificationsBloc();
