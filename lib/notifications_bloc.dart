import 'package:moengage_flutter/inapp_campaign.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:moengage_flutter/push_campaign.dart';
import 'package:moengage_flutter/push_token.dart';

class NotificationsBloc {
  final MoEngageFlutter _moengagePlugin = MoEngageFlutter();

  initialise() {
    _moengagePlugin.initialise();
    _moengagePlugin.enableSDKLogs();
    _moengagePlugin.setUpPushTokenCallback(_onPushTokenGenerated);
    _moengagePlugin.setUpPushCallbacks(_onPushClick);
    _moengagePlugin.setUpInAppCallbacks(
      onInAppClick: _onInAppClick,
      onInAppShown: _onInAppShown,
      onInAppDismiss: _onInAppDismiss,
      onInAppCustomAction: _onInAppCustomAction,
      onInAppSelfHandle: _onInAppSelfHandle,
    );
  }

  void _onPushTokenGenerated(PushToken pushToken) {
    print(
        "This is callback on push token generated from native to flutter: PushToken: " +
            pushToken.toString());
  }

  void _onPushClick(PushCampaign message) {
    print("This is a push click callback from native to flutter. Payload " +
        message.toString());
  }

  void _onInAppClick(InAppCampaign message) {
    print("This is a inapp click callback from native to flutter. Payload " +
        message.toString());
  }

  void _onInAppShown(InAppCampaign message) {
    print("This is a callback on inapp shown from native to flutter. Payload " +
        message.toString());
  }

  void _onInAppDismiss(InAppCampaign message) {
    print(
        "This is a callback on inapp dismiss from native to flutter. Payload " +
            message.toString());
  }

  void _onInAppCustomAction(InAppCampaign message) {
    print(
        "This is a callback on inapp custom action from native to flutter. Payload " +
            message.toString());
  }

  void _onInAppSelfHandle(InAppCampaign message) {
    print(
        "This is a callback on inapp self handle from native to flutter. Payload " +
            message.toString());
    _moengagePlugin.selfHandledShown(message);
    _moengagePlugin.selfHandledClicked(message);
    _moengagePlugin.selfHandledPrimaryClicked(message);
    _moengagePlugin.selfHandledDismissed(message);
  }

  @override
  void dispose() {}
}

final NotificationsBloc notificationsBloc = NotificationsBloc();
