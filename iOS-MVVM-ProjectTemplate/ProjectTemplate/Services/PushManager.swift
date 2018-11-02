import ReactiveSwift
import UserNotifications

protocol HasPushManager {
    var pushManager: PushManaging { get }
}

protocol PushManagingNotifications {
    /// Signal of received payloads while app is in foreground
    var received: Signal<PushNotification.Payload, NoError> { get }

    /// Signal of notifications which were opened by the user
    var opened: Signal<PushNotification, NoError> { get }
}

protocol PushManagingActions {
    /// Register new token
    var registerToken: Action<String, Void, RequestError> { get }
}

protocol PushManaging {
    var notifications: PushManagingNotifications { get }
    var actions: PushManagingActions { get }

    func start()
}

final class PushManager: NSObject, PushManaging, PushManagingNotifications, PushManagingActions {
    typealias Dependencies = HasPushAPI

    var notifications: PushManagingNotifications { return self }
    var actions: PushManagingActions { return self }

    let (received, receivedObserver) = Signal<PushNotification.Payload, NoError>.pipe()
    let (opened, openedObserver) = Signal<PushNotification, NoError>.pipe()
    let registerToken: Action<String, Void, RequestError>

    // MARK: Initializers

    init(dependencies: Dependencies) {
        registerToken = Action { dependencies.pushAPI.registerToken($0) }
    }

    // MARK: Public interface

    func start() {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension PushManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let pushNotification = PushNotification(response: response) {
            openedObserver.send(value: pushNotification)
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let payload = PushNotification.Payload(notification: notification) {
            receivedObserver.send(value: payload)
        }
        completionHandler([.alert, .badge, .sound])
    }
}
