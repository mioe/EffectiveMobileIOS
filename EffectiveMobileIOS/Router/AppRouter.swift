// by mioe

import SwiftUI

// MARK: - AppRoute

enum AppRoute: Hashable {
	case todoCreate  // /todo
	case todoEdit  // /todo/{uuid}
}

// MARK: - AppRouter

@Observable
@MainActor
class AppRouter {
	var navigationPath = NavigationPath()
	
	func openTodo() {
		navigationPath.append(AppRoute.todoCreate)
	}
	
	func pop() {
		if !navigationPath.isEmpty { navigationPath.removeLast() }
	}
	
	func popToRoot() {
		navigationPath = NavigationPath()
	}
}
