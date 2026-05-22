// by mioe

import SwiftUI

struct MainView: View {

	@Environment(AppRouter.self) private var router

	let onTapAbout: () -> Void

	var body: some View {
		VStack(spacing: 0) {
			ScrollView {
				VStack {
					Text("MainView")
						.foregroundStyle(.accent)
					Button {
						router.openTodo()
					} label: {
						Text("test")
					}

					HStack {
						Image(.iEdit)
							.resizable()
							.frame(width: 16, height: 16)
							.foregroundStyle(.accent)
						Image(.iTrash)
							.resizable()
							.frame(width: 16, height: 16)
							.foregroundStyle(.red)
						Image(.iExport)
							.resizable()
							.frame(width: 16, height: 16)
					}
				}
			}
			.scrollClipDisabled()
			.scrollIndicators(.hidden)
			.padding(.horizontal, 20)

			FooterView()
				.frame(maxWidth: .infinity)
				.frame(alignment: .bottom)
		}
		.navigationTitle("Todos")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					onTapAbout()
				} label: {
					Image(systemName: "questionmark")
				}
			}
		}
	}

	@ViewBuilder
	private func FooterView() -> some View {
		VStack(spacing: 0) {
			Divider()
			HStack(spacing: 16) {
				Rectangle().fill(.primary.opacity(0)).frame(width: 68)
				Spacer(minLength: 0)
				Text("7 Todos")
					.font(.system(size: 11))
				Spacer(minLength: 0)
				Button {
					router.openTodo()
				} label: {
					Image(systemName: "square.and.pencil")
						.foregroundStyle(.accent)
						.font(.system(size: 22))
						.frame(width: 68)
						.contentShape(.rect)
				}
				.buttonStyle(.plain)
			}
			.padding(.horizontal, 20)
			.frame(height: 48)
		}
		.background(.background)
	}
}
