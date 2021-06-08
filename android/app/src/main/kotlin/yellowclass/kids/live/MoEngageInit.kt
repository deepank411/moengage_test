package yellowclass.kids.live

import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Parcelable
import com.moengage.core.LogLevel
import com.moengage.core.MoEngage
import com.moengage.core.config.FcmConfig
import com.moengage.core.config.LogConfig
import com.moengage.core.config.NotificationConfig
import com.moengage.core.config.PushKitConfig
import com.moengage.core.internal.utils.JsonBuilder
import com.moengage.flutter.MoEInitializer
import com.moengage.plugin.base.*
import com.moengage.pushbase.MoEPushHelper
import com.moengage.pushbase.PushConstants
import com.moengage.pushbase.model.action.NavigationAction
import io.flutter.app.FlutterApplication
import org.json.JSONObject
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap

class MoEngageInit : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        //val moEngage = MoEngage.Builder(this, "KPSBSYK7082WT0ORCVMJ46XX") // yellowclass_prod app on moengage
         val moEngage = MoEngage.Builder(this, "2LG1TDV6NRAV4BCR82NVWDC2") // yellowclass_staging app on moengage
                .configureNotificationMetaData(
                        NotificationConfig(
                                R.drawable.notify_icon_72,
                                R.drawable.notify_icon_256,
                                R.color.noti_col,
                                null,
                                true,
                                isBuildingBackStackEnabled = false,
                                isLargeIconDisplayEnabled = true)
                )
                .configureLogs(LogConfig(LogLevel.VERBOSE, true))
                .configureFcm(FcmConfig(true))
                .configurePushKit(PushKitConfig(true))
        //.configureMiPush(MiPushConfig("2882303761518042309", "5601804211309", true))
        MoEInitializer.initialize(applicationContext, moEngage)
        MoEPushHelper.getInstance().messageListener = CustomPushListener()
    }
}

class CustomPushListener:PluginPushCallback() {

    override fun onNotificationReceived(context: Context, payload: Bundle) {
        super.onNotificationReceived(context, payload)
        Handler(Looper.getMainLooper()).post {
            SingletonNotificationChannel.notificationChannel?.invokeMethod("onReceived", pushPayloadToMap(payload))
        }
    }

    override fun isNotificationRequired(context: Context, payload: Bundle): Boolean {
        val shouldDisplayNotification = super.isNotificationRequired(context, payload)
        // do not show notification if MoEngage SDK returns false.
        if (shouldDisplayNotification) {
            val df1: DateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
            df1.setTimeZone(TimeZone.getTimeZone("GMT"));
            val string1 = payload.get("staleAt").toString()
            val staleAt:Date = df1.parse(string1)
            val currentTime: Date = Date()
            return !staleAt.before(currentTime)
        }
        return shouldDisplayNotification
    }

    private fun pushPayloadToMap(bundle: Bundle): Map<String, Any> {
        val map: MutableMap<String, Any> = HashMap()
        val keys: Set<String> = bundle.keySet()
        for (key in keys) {
            if (key == PushConstants.NAV_ACTION) {
                val parcel: Parcelable? = bundle.getParcelable(key)
                if (parcel != null){
                    val navigationAction = parcel as NavigationAction
                    map[transform(key, keyMapper)] = getNavClickActionJson(navigationAction)
                }
            } else {
                val value = bundle.get(key)
                if (value != null) {
                    map[transform(key, keyMapper)] = value
                }
            }
        }
        return map
    }

    private fun getNavClickActionJson(navigationAction: NavigationAction): JSONObject {
        val clickedJson = JsonBuilder()
        clickedJson.putString(PARAM_ACTION_TYPE, ACTION_TYPE_NAVIGATION)
        clickedJson.putJsonObject(ARGUMENT_PAYLOAD, navigationActionToJson(navigationAction))
        return clickedJson.build()
    }
}
