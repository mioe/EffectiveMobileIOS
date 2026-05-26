// by mioe

import SwiftUI

// MARK: - AppRoute

enum AppRoute: Hashable {
	case todoFormCreate  // /todo
	case todoFormEdit(UUID)  // /todo/{uuid}
}

// MARK: - AppRouter

@Observable
@MainActor
class AppRouter {
	var navigationPath = NavigationPath()

	func push(_ route: AppRoute) {
		navigationPath.append(route)
	}

	func pop() {
		if !navigationPath.isEmpty { navigationPath.removeLast() }
	}

	func popToRoot() {
		navigationPath = NavigationPath()
	}
}
