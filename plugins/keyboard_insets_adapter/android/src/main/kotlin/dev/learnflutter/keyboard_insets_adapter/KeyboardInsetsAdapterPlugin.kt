package dev.learnflutter.keyboard_insets_adapter

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.max

class KeyboardInsetsAdapterPlugin :
    // 插件接入 Flutter engine。
    FlutterPlugin,
    // 处理 Dart 调 native 的方法。
    MethodChannel.MethodCallHandler,
    // 拿到 Android 当前 Activity。
    ActivityAware {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private val mainHandler = Handler(Looper.getMainLooper())

    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null
    private var listenerView: View? = null
    private var currentHeightPx = 0
    private var isKeyboardVisible = false
    private var isAnimating = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    setupKeyboardTracking(enableEdgeToEdge = false)
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            },
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        teardownKeyboardTracking()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "configure" -> {
                val enableEdgeToEdge = call.argument<Boolean>("androidEdgeToEdge") ?: false
                setupKeyboardTracking(enableEdgeToEdge = enableEdgeToEdge)
                result.success(null)
            }

            "dismiss" -> {
                dismissKeyboard(keepFocus = call.argument<Boolean>("keepFocus") ?: false)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        setupKeyboardTracking(enableEdgeToEdge = false)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        teardownKeyboardTracking()
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        setupKeyboardTracking(enableEdgeToEdge = false)
    }

    override fun onDetachedFromActivity() {
        teardownKeyboardTracking()
        activity = null
    }

    private fun setupKeyboardTracking(enableEdgeToEdge: Boolean) {
        val act = activity ?: return
        val decorView = act.window.decorView ?: return

        if (enableEdgeToEdge) {
            WindowCompat.setDecorFitsSystemWindows(act.window, false)
        }

        if (listenerView === decorView) return
        teardownKeyboardTracking()
        listenerView = decorView

        ViewCompat.setOnApplyWindowInsetsListener(decorView) { view, insets ->
            if (!isAnimating) {
                val heightPx = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom
                updateAndEmit(
                    type = if (heightPx > 0) "keyboardDidShow" else "keyboardDidHide",
                    heightPx = heightPx,
                    progress = if (heightPx > 0) 1.0 else 0.0,
                    durationMillis = 0.0,
                    view = view,
                )
            }
            ViewCompat.onApplyWindowInsets(view, insets)
        }

        ViewCompat.setWindowInsetsAnimationCallback(
            decorView,
            object : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE) {
                private var startHeightPx = 0
                private var endHeightPx = 0

                override fun onPrepare(animation: WindowInsetsAnimationCompat) {
                    isAnimating = true
                    startHeightPx = currentHeightPx
                }

                override fun onStart(
                    animation: WindowInsetsAnimationCompat,
                    bounds: WindowInsetsAnimationCompat.BoundsCompat,
                ): WindowInsetsAnimationCompat.BoundsCompat {
                    val rootImeBottom = ViewCompat.getRootWindowInsets(decorView)
                        ?.getInsets(WindowInsetsCompat.Type.ime())
                        ?.bottom ?: 0
                    endHeightPx = max(rootImeBottom, bounds.upperBound.bottom)

                    val isShowing = endHeightPx > startHeightPx
                    emitEvent(
                        type = if (isShowing) "keyboardWillShow" else "keyboardWillHide",
                        heightPx = if (isShowing) endHeightPx else startHeightPx,
                        progress = if (isShowing) 0.0 else 1.0,
                        durationMillis = animation.durationMillis.toDouble(),
                        view = decorView,
                        isVisible = isShowing || startHeightPx > 0,
                    )
                    return bounds
                }

                override fun onProgress(
                    insets: WindowInsetsCompat,
                    runningAnimations: List<WindowInsetsAnimationCompat>,
                ): WindowInsetsCompat {
                    val heightPx = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom
                    val imeAnimation = runningAnimations.firstOrNull {
                        it.typeMask and WindowInsetsCompat.Type.ime() != 0
                    }
                    val maxHeightPx = max(max(startHeightPx, endHeightPx), heightPx).toDouble()
                    val progress = if (maxHeightPx > 0) {
                        (heightPx.toDouble() / maxHeightPx).coerceIn(0.0, 1.0)
                    } else {
                        0.0
                    }

                    updateAndEmit(
                        type = "keyboardMove",
                        heightPx = heightPx,
                        progress = progress,
                        durationMillis = (imeAnimation?.durationMillis ?: 0).toDouble(),
                        view = decorView,
                    )
                    return insets
                }

                override fun onEnd(animation: WindowInsetsAnimationCompat) {
                    val heightPx = ViewCompat.getRootWindowInsets(decorView)
                        ?.getInsets(WindowInsetsCompat.Type.ime())
                        ?.bottom ?: 0
                    isAnimating = false
                    updateAndEmit(
                        type = if (heightPx > 0) "keyboardDidShow" else "keyboardDidHide",
                        heightPx = heightPx,
                        progress = if (heightPx > 0) 1.0 else 0.0,
                        durationMillis = animation.durationMillis.toDouble(),
                        view = decorView,
                    )
                }
            },
        )

        ViewCompat.requestApplyInsets(decorView)
    }

    private fun teardownKeyboardTracking() {
        listenerView?.let { view ->
            ViewCompat.setOnApplyWindowInsetsListener(view, null)
            ViewCompat.setWindowInsetsAnimationCallback(view, null)
        }
        listenerView = null
        isAnimating = false
    }

    private fun dismissKeyboard(keepFocus: Boolean) {
        val act = activity ?: return
        val focused = act.currentFocus ?: act.window.decorView
        val imm = act.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(focused.windowToken, 0)

        if (!keepFocus) {
            focused.clearFocus()
        }
    }

    private fun updateAndEmit(
        type: String,
        heightPx: Int,
        progress: Double,
        durationMillis: Double,
        view: View,
    ) {
        currentHeightPx = max(0, heightPx)
        isKeyboardVisible = currentHeightPx > 0
        emitEvent(
            type = type,
            heightPx = currentHeightPx,
            progress = progress,
            durationMillis = durationMillis,
            view = view,
            isVisible = isKeyboardVisible,
        )
    }

    private fun emitEvent(
        type: String,
        heightPx: Int,
        progress: Double,
        durationMillis: Double,
        view: View,
        isVisible: Boolean,
    ) {
        val density = view.resources.displayMetrics.density
        val event = mapOf(
            "type" to type,
            "height" to (max(0, heightPx).toDouble() / density),
            "progress" to progress.coerceIn(0.0, 1.0),
            "isVisible" to isVisible,
            "duration" to durationMillis,
            "timestamp" to System.currentTimeMillis().toDouble(),
        )

        mainHandler.post {
            eventSink?.success(event)
        }
    }

    companion object {
        private const val METHOD_CHANNEL = "keyboard_insets_adapter"
        private const val EVENT_CHANNEL = "keyboard_insets_adapter/events"
    }
}
