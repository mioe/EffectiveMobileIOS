// by mioe

import SwiftUI

@main
struct EffectiveMobileIOSApp: App {

	init() {
		print(URL.applicationSupportDirectory.path(percentEncoded: false))
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
