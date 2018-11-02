import ReactiveSwift

typealias LoginResult = (Credentials, User)
typealias LoginAction = Action<LoginCredentials, LoginResult, RequestError>
typealias LogoutAction = Action<Void, Void, RequestError>

protocol HasUserManager {
    var userManager: UserManaging { get }
}

protocol UserManagingActions {
    var login: LoginAction { get }
    var logout: LogoutAction { get }
}

protocol UserManaging {
    var actions: UserManagingActions { get }

    var isLoggedIn: Property<Bool> { get }
    var user: Property<User?> { get }
}

final class UserManager: UserManaging, UserManagingActions {
    var actions: UserManagingActions { return self }

    lazy var isLoggedIn = user.map { $0 != nil }
    let user = Property<User?>(value: nil)

    let login = LoginAction { _ in .empty }
    let logout = LogoutAction { .empty }
}
