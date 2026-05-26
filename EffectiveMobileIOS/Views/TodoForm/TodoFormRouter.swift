// by mioe

import SwiftUI

@MainActor
protocol TodoFormRouterProtocol: AnyObject {
	func dismiss()
}

@MainActor
final class TodoFormRouter: TodoFormRouterProtocol {
	
	private let appRouter: AppRouter
	
	init(appRouter: AppRouter) {
		self.appRouter = appRouter
	}
	
	func dismiss() {
		appRouter.pop()
	}
	
	static func build(
		mode: TodoFormMode,
		appRouter: AppRouter,
		repository: TodoRepositoryProtocol
	) -> TodoFormView {
		let interactor = TodoFormInteractor(repository: repository)
		let router = TodoFormRouter(appRouter: appRouter)
		let presenter = TodoFormPresenter(mode: mode, interactor: interactor, router: router)
		interactor.presenter = presenter
		return TodoFormView(presenter: presenter)
	}
}
