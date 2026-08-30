package com.example.budget_wise
import android.animation.AnimatorSet
import android.animation.ObjectAnimator.ofFloat
import android.os.Bundle
import android.view.View
import android.view.animation.AnticipateInterpolator
import android.view.animation.DecelerateInterpolator
import androidx.core.animation.doOnEnd
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.shounakmulay.telephony.TelephonyPlugin

class MainActivity : FlutterFragmentActivity() {
    private var isFlutterReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()

        super.onCreate(savedInstanceState)

        val startTime = System.currentTimeMillis()

        // Tells Android to keep the splash screen visible until the flutter engine say so
        splashScreen.setKeepOnScreenCondition { 
          val elapsed = System.currentTimeMillis() - startTime
          !isFlutterReady || elapsed < 1000L
        }

        // Exit Animation
        splashScreen.setOnExitAnimationListener { splashScreenView ->
          val iconView = splashScreenView.iconView
          
          // 1. SCALE DOWN (Shrink): From 1.0 (Normal) to 0.3 (Smaller)
          val scaleX = ofFloat(iconView, View.SCALE_X, 1f, 0.3f).apply {
            interpolator = AnticipateInterpolator()
          }
          val scaleY = ofFloat(iconView, View.SCALE_Y, 1f, 0.3f).apply {
            interpolator = AnticipateInterpolator()
          }

          // 2. FADE OUT: Make the whole screen (icon + background) disappear
          val fadeOut = ofFloat(splashScreenView.view, View.ALPHA, 1f, 0f).apply {
            interpolator = DecelerateInterpolator()
          }

          // 3. Group them together
          val animatorSet = AnimatorSet().apply {
            duration = 400L
            playTogether(scaleX, scaleY, fadeOut)
          }


          // 4. Remove the view once finished
          animatorSet.doOnEnd {
            splashScreenView.remove()
          }
          
          // 5. Start the animation
          animatorSet.start()
        }

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(TelephonyPlugin())

        // Set up the bridge between kotlin and flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.budget_wise/init").setMethodCallHandler { call, result ->
            if (call.method == "onFlutterReady") {
                isFlutterReady = true
                result.success(null)
            }
        }
    }
}
