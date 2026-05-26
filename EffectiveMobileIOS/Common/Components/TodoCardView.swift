// by mioe

import SwiftUI

struct TodoCardView: View {

	let todo: TodoListItem
	let onToggleDone: () -> Void
	let onTap: () -> Void
	let onEdit: () -> Void
	let onDelete: () -> Void

	var body: some View {
		Button {
			onTap()
		} label: {
			HStack(alignment: .top, spacing: 8) {
				CheckboxView()
				ContentView()
			}
			.padding(.vertical, 12)
		}
		.buttonStyle(.plain)
		.contextMenu {
			MenuItems()
		} preview: {
			HStack(spacing: 0) {
				ContentView()
			}
			.padding(.vertical, 12)
			.padding(.horizontal, 16)
			.frame(width: 320)
		}
	}

	@ViewBuilder
	private func CheckboxView() -> some View {
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
	}

	@ViewBuilder
	private func ContentView() -> some View {
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
					.foregroundStyle(.secondary)
			}
			.foregroundStyle(todo.isDone ? .secondary : .primary)
			Spacer(minLength: 0)
		}
		.frame(maxWidth: .infinity)
		.contentShape(.rect)
	}

	@ViewBuilder
	private func MenuItems() -> some View {
		Button {
			onEdit()
		} label: {
			Label("Edit", image: "i-edit")
		}

		ShareLink(item: shareText) {
			Label("Share", image: "i-export")
		}

		Button(role: .destructive) {
			onDelete()
		} label: {
			Label("Delete", image: "i-trash")
		}
	}

	private var shareText: String {
		if let text = todo.text, !text.isEmpty {
			return "\(todo.name)\n\(text)"
		}
		return todo.name
	}
}
