import Flutter
import UIKit

public class KeyboardInsetsAdapterPlugin: NSObject, FlutterPlugin {
    private var eventSink: FlutterEventSink?
    private var currentKeyboardHeight: CGFloat = 0
    private var isVisible = false
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var animationDuration: CFTimeInterval = 0
    private var animationStartHeight: CGFloat = 0
    private var animationEndHeight: CGFloat = 0
    private var animationCurve: UIView.AnimationCurve = .easeInOut
    private var pendingDidHide = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = KeyboardInsetsAdapterPlugin()
        let methodChannel = FlutterMethodChannel(
            name: "keyboard_insets_adapter",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "keyboard_insets_adapter/events",
            binaryMessenger: registrar.messenger()
        )

        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public override init() {
        super.init()
        registerKeyboardNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopDisplayLink()
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        NotificationCenter.default.removeObserver(self)
        stopDisplayLink()
        eventSink = nil
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            result(nil)
        case "dismiss":
            let args = call.arguments as? [String: Any]
            dismissKeyboard(keepFocus: args?["keepFocus"] as? Bool ?? false)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func registerKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidShow(_:)),
                           name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidHide(_:)),
                           name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboard = keyboardInfo(from: notification) else { return }
        pendingDidHide = false
        isVisible = true
        emit(type: "keyboardWillShow", height: keyboard.height, progress: 0, duration: keyboard.duration)
        startDisplayLink(from: currentKeyboardHeight, to: keyboard.height,
                         duration: keyboard.duration, curve: keyboard.curve)
    }

    @objc private func keyboardDidShow(_ notification: Notification) {
        guard let keyboard = keyboardInfo(from: notification) else { return }
        stopDisplayLink()
        currentKeyboardHeight = keyboard.height
        isVisible = keyboard.height > 0
        emit(type: "keyboardDidShow", height: keyboard.height,
             progress: isVisible ? 1 : 0, duration: 0)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let keyboard = keyboardInfo(from: notification) else { return }
        emit(type: "keyboardWillHide", height: currentKeyboardHeight,
             progress: 1, duration: keyboard.duration)
        startDisplayLink(from: currentKeyboardHeight, to: 0,
                         duration: keyboard.duration, curve: keyboard.curve)
    }

    @objc private func keyboardDidHide(_ notification: Notification) {
        isVisible = false
        if displayLink != nil {
            pendingDidHide = true
            return
        }

        currentKeyboardHeight = 0
        emit(type: "keyboardDidHide", height: 0, progress: 0, duration: 0)
    }

    private func keyboardInfo(from notification: Notification) -> KeyboardInfo? {
        guard let userInfo = notification.userInfo else { return nil }
        let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? UIView.AnimationCurve.easeInOut.rawValue
        let curve = UIView.AnimationCurve(rawValue: curveRaw) ?? .easeInOut
        return KeyboardInfo(height: obscuredHeight(forKeyboardFrame: frame),
                            duration: duration, curve: curve)
    }

    private func obscuredHeight(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
        guard let window = activeKeyWindow() else { return 0 }
        let frameInWindow = window.convert(keyboardFrame, from: nil)
        let intersection = window.bounds.intersection(frameInWindow)

        if intersection.isNull || intersection.isEmpty {
            return 0
        }

        return max(0, intersection.height)
    }

    private func activeKeyWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter {
                $0.activationState == .foregroundActive ||
                $0.activationState == .foregroundInactive
            }

        for scene in scenes {
            if let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow
            }
        }

        return scenes.first?.windows.first
    }

    private func startDisplayLink(
        from startHeight: CGFloat,
        to endHeight: CGFloat,
        duration: CFTimeInterval,
        curve: UIView.AnimationCurve
    ) {
        stopDisplayLink()

        guard duration > 0 else {
            currentKeyboardHeight = endHeight
            let maxHeight = max(startHeight, endHeight)
            let progress = maxHeight > 0 ? Double(endHeight / maxHeight) : 0
            emit(type: "keyboardMove", height: endHeight, progress: progress, duration: 0)
            finishDisplayLinkIfNeeded()
            return
        }

        animationStartHeight = startHeight
        animationEndHeight = endHeight
        animationDuration = duration
        animationCurve = curve
        animationStartTime = CACurrentMediaTime()

        let link = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func displayLinkTick() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        let rawProgress = min(elapsed / animationDuration, 1)
        let easedProgress = applyAnimationCurve(rawProgress)
        let currentHeight = animationStartHeight +
            (animationEndHeight - animationStartHeight) * CGFloat(easedProgress)

        currentKeyboardHeight = currentHeight
        let maxHeight = max(animationStartHeight, animationEndHeight)
        let progress = maxHeight > 0 ? Double(currentHeight / maxHeight) : 0

        emit(type: "keyboardMove", height: currentHeight,
             progress: progress.clamped(to: 0...1),
             duration: animationDuration * 1000)

        if rawProgress >= 1 {
            finishDisplayLinkIfNeeded()
        }
    }

    private func finishDisplayLinkIfNeeded() {
        stopDisplayLink()
        if pendingDidHide {
            pendingDidHide = false
            currentKeyboardHeight = 0
            emit(type: "keyboardDidHide", height: 0, progress: 0, duration: 0)
        }
    }

    private func applyAnimationCurve(_ progress: Double) -> Double {
        if animationCurve.rawValue == 7 {
            let inverse = 1 - progress
            return 1 - inverse * inverse * inverse
        }

        switch animationCurve {
        case .easeIn:
            return progress * progress
        case .easeOut:
            return progress * (2 - progress)
        case .easeInOut:
            if progress < 0.5 {
                return 2 * progress * progress
            }
            return -1 + (4 - 2 * progress) * progress
        default:
            return progress
        }
    }

    private func emit(type: String, height: CGFloat, progress: Double, duration: Double) {
        guard let sink = eventSink else { return }
        sink([
            "type": type,
            "height": Double(max(0, height)),
            "progress": progress.clamped(to: 0...1),
            "isVisible": type == "keyboardDidHide" ? false : max(0, height) > 0 || isVisible,
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970 * 1000,
        ])
    }

    private func dismissKeyboard(keepFocus: Bool) {
        guard !keepFocus else { return }
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension KeyboardInsetsAdapterPlugin: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

private struct KeyboardInfo {
    let height: CGFloat
    let duration: Double
    let curve: UIView.AnimationCurve
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
