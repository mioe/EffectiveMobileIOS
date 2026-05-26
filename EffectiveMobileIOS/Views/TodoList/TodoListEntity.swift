// by mioe

import Foundation

struct TodoListItem: Identifiable, Hashable {
	let id: UUID
	let name: String
	let text: String?
	let createdAt: Date
	let isDone: Bool
}

extension TodoListItem {
	nonisolated init(todo: Todo) {
		self.init(
			id: todo.id,
			name: todo.name,
			text: todo.text,
			createdAt: todo.createdAt,
			isDone: todo.done
		)
	}
}
