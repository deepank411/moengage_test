package yellowclass.kids.live

import android.app.Application
import com.moengage.core.LogLevel
import com.moengage.core.MoEngage
import com.moengage.core.config.FcmConfig
import com.moengage.core.config.LogConfig
import com.moengage.core.config.NotificationConfig
import com.moengage.core.config.PushKitConfig
import com.moengage.flutter.MoEInitializer
import io.flutter.app.FlutterApplication


class MoEngageInit : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        val moEngage = MoEngage.Builder(this, "8ADXNUXU6BVIBYQDL12505AS")
                .configureNotificationMetaData(
                        NotificationConfig(
                                R.drawable.icon,
                                R.drawable.ic_launcher,
                                -1,
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
    }
}