import UserNotifications

/// Model object for push notification
///
/// When user opens a notification this object should be created
struct PushNotification {
    /// Payload of push notification
    ///
    /// When notification is received (*NOT* opened) while the app is in foreground
    /// instance of this object should be created
    struct Payload {

    }

    /// List of actions which can be triggered when opening a notification
    ///
    /// Probably just add `String` raw value.
    /// Unluckily enum with raw value must have some cases so it is not possible to have it here empty
    enum Action {

    }

    /// Action which triggered opening of this notification
    ///
    /// Is `nil` if notification was opened without any action
    let action: Action?

    /// Content data of notification
    let payload: Payload
}

extension PushNotification {
    init?(response: UNNotificationResponse) {
        guard let payload = Payload(notification: response.notification) else { return nil }

        self.payload = payload
        self.action = Action(actionID: response.actionIdentifier)
    }
}

extension PushNotification.Action {
    init?(actionID: String) {
        return nil // TODO: Implement if any actions, probably add String as rawValue and delegate to `init(rawValue:)`
    }
}

extension PushNotification.Payload {
    init?(notification: UNNotification) {
        return nil // TODO: Implement payload mapping
    }
}

