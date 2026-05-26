// by mioe

import SwiftUI

struct ContentView: View {

	@State private var router = AppRouter()
	@State private var isExpanded: Bool = false

	private let repository: TodoRepositoryProtocol = TodoRepository()

	var body: some View {
		let isMenuEnabled = router.navigationPath.isEmpty

		AppSideMenuView(
			isEnabled: isMenuEnabled,
			isExpanded: $isExpanded
		) { progress in
			AboutMe()
		} content: { progress in
			NavigationStack(path: $router.navigationPath) {
				TodoListRouter.build(
					appRouter: router,
					repository: repository,
					onTapAbout: { isExpanded = true }
				)
				.navigationDestination(for: AppRoute.self) { route in
					switch route {
					case .todoFormCreate:
						TodoFormRouter.build(
							mode: .create,
							appRouter: router,
							repository: repository
						)
					case .todoFormEdit(let id):
						TodoFormRouter.build(
							mode: .edit(id),
							appRouter: router,
							repository: repository
						)
					}
				}
			}
		}
		.environment(router)
	}
}
