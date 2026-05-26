// by mioe

import SwiftUI

struct TodoListView: View {

	@StateObject var presenter: TodoListPresenter

	let onTapAbout: () -> Void

	var body: some View {
		VStack(spacing: 0) {
			ScrollView {
				BodyView()
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
		.searchable(
			text: $presenter.searchPrompt,
			placement: .navigationBarDrawer(displayMode: .always),
			prompt: "Search"
		)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					onTapAbout()
				} label: {
					Image(systemName: "questionmark")
				}
			}
		}
		.task {
			presenter.viewDidAppear()
		}
		.alert(
			"Err",
			isPresented: Binding(
				get: { presenter.errorMessage != nil },
				set: { if !$0 { presenter.errorMessage = nil } }
			),
			presenting: presenter.errorMessage
		) { _ in
			Button("OK", role: .cancel) {}
		} message: { message in
			Text(message)
		}
	}

	@ViewBuilder
	private func BodyView() -> some View {
		if presenter.items.isEmpty {
			Text("Empty...")
				.foregroundStyle(.secondary)
				.padding(.vertical, 20)
		} else {
			CustomListDivider {
				ForEach(presenter.items, id: \.id) { item in
					TodoCardView(
						todo: item,
						onToggleDone: { presenter.handleDoneTodo(item) },
						onTap: { presenter.handleSelectTodo(item) },
						onEdit: { presenter.handleSelectTodo(item) },
						onDelete: { presenter.handleDeleteTodo(item) }
					)
					.swipeActions {
						AppAction(
							icon: "trash.fill",
							tint: .red,
							background: .secondary.opacity(0)
						) { resetTrigger in
							presenter.handleDeleteTodo(item)
							resetTrigger.toggle()
						}
					}
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
				Text(presenter.todosCount)
					.font(.system(size: 11))
				Spacer(minLength: 0)
				Button {
					presenter.handleCreateTodo()
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
