// by mioe

import Foundation
import Combine

protocol TodoListPresenterProtocol: AnyObject {
	func didFetchTodo(todos: [Todo])
}

final class TodoListPresenter: TodoListPresenterProtocol, ObservableObject {
	@Published var todos: [Todo] = []
	
	func didFetchTodo(todos: [Todo]) {
		self.todos = todos
	}
}
