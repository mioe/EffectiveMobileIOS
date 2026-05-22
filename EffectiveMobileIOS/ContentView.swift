// by mioe

import SwiftUI

struct ContentView: View {
	
	@State private var router = AppRouter()
	@State private var isExpanded: Bool = false
	
	var body: some View {
		let isMenuEnabled = router.navigationPath.isEmpty
		
		AppSideMenuView(
			isEnabled: isMenuEnabled,
			isExpanded: $isExpanded
		) { progress in
			HStack {
				Text("Misha")
			}
		} content: { progress in
			NavigationStack(path: $router.navigationPath) {
				MainView()
				.navigationTitle("Application")
				.navigationBarTitleDisplayMode(.inline)
				.navigationDestination(for: AppRoute.self) { value in
					switch value {
					case .todoCreate:
						TodoView()
					case .todoEdit:
						TodoView()
					}
				}
			}
		}
		.environment(router)
	}
}
