// by mioe

import SwiftUI

struct TodoCardView: View {

	let todo: TodoListItem
	let onToggleDone: () -> Void
	let onTap: () -> Void

	var body: some View {
		Button {
			onTap()
		} label: {
			HStack(alignment: .top, spacing: 8) {
				VStack(spacing: 0) {
					Button {
						onToggleDone()
					} label: {
						Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
							.font(.system(size: 24))
							.foregroundStyle(todo.isDone ? Color.accentColor : .secondary)
					}
					.buttonStyle(.plain)
				}
				HStack(spacing: 0) {
					VStack(alignment: .leading, spacing: 6) {
						Text(todo.name)
							.font(.system(size: 16, weight: .medium))
							.lineLimit(1)
							.truncationMode(.tail)
							.strikethrough(todo.isDone)
						if let text = todo.text {
							Text(text)
								.font(.system(size: 12))
								.lineLimit(2)
								.truncationMode(.tail)
						}
						DateFormatedText(date: todo.createdAt)
							.font(.system(size: 12))
					}
					.foregroundStyle(todo.isDone ? .secondary : .primary)
					Spacer(minLength: 0)
				}
				.frame(maxWidth: .infinity)
				.contentShape(.rect)
			}
			.padding(.vertical, 12)
		}
		.buttonStyle(.plain)
	}
}
