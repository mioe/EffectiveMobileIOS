// by mioe

import SwiftUI

struct TodoView: View {
	
	@Environment(AppRouter.self) private var router

	@State var title: String = ""
	@State var content: String = ""

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				VStack(alignment: .leading, spacing: 8) {
					TextField("title", text: $title)
						.font(.system(size: 34, weight: .bold))
					Text("02/10/24")
						.font(.system(size: 12))
						.foregroundStyle(.secondary)
				}

				TextField("description", text: $content)
					.font(.system(size: 16))
			}
		}
		.scrollClipDisabled()
		.scrollIndicators(.hidden)
		.padding(.horizontal, 20)
	}
}
