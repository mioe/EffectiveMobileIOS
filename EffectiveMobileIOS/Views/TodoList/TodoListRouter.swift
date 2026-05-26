// by mioe

import SwiftUI

@MainActor
protocol TodoListRouterProtocol: AnyObject {
	func goTodoCreate()
	func goTodoEdit(id: UUID)
}

@MainActor
final class TodoListRouter: TodoListRouterProtocol {
	
	private let appRouter: AppRouter
	
	init(appRouter: AppRouter) {
		self.appRouter = appRouter
	}
	
	func goTodoCreate() {
		appRouter.push(.todoFormCreate)
	}
	
	func goTodoEdit(id: UUID) {
		appRouter.push(.todoFormEdit(id))
	}
	
	static func build(
		appRouter: AppRouter,
		repository: TodoRepositoryProtocol,
		onTapAbout: @escaping () -> Void
	) -> TodoListView {
		let interactor = TodoListInteractor(repository: repository)
		let router = TodoListRouter(appRouter: appRouter)
		let presenter = TodoListPresenter(interactor: interactor, router: router)
		interactor.presenter = presenter
		return TodoListView(presenter: presenter, onTapAbout: onTapAbout)
	}
}
