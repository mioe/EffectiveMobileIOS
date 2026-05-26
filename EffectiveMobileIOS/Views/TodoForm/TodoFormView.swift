// by mioe

import SwiftUI

struct TodoFormView: View {
	
	@StateObject var presenter: TodoFormPresenter

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				VStack(alignment: .leading, spacing: 8) {
					TextField("title", text: $presenter.name)
						.font(.system(size: 34, weight: .bold))
					if let createdAt = presenter.createdAt {
						DateFormatedText(date: createdAt)
							.font(.system(size: 12))
							.foregroundStyle(.secondary)
					}
				}

				TextField("description", text: $presenter.text)
					.font(.system(size: 16))
			}
		}
		.scrollClipDisabled()
		.scrollIndicators(.hidden)
		.padding(.horizontal, 20)
	}
}
