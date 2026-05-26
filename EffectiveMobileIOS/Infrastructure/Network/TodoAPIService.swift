// by mioe

import Foundation

// MARK: - DTO

nonisolated struct TodoListResponseDTO: Decodable {
	let todos: [TodoDTO]
}

nonisolated struct TodoDTO: Decodable {
	let id: Int
	let todo: String
	let completed: Bool
}

// MARK: - Errors

enum TodoAPIError: LocalizedError {
	case invalidURL
	case emptyResponse

	var errorDescription: String? {
		switch self {
		case .invalidURL: "🦕 invalid url"
		case .emptyResponse: "🦕 response is empty"
		}
	}
}

// MARK: - Service

protocol TodoAPIServiceProtocol: AnyObject {
	func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void)
}

/// загрузка задач из dummyjson, callback `URLSession` приходит на фоновом
/// потоке - разбор JSON также выполняется вне главного потока
final class TodoAPIService: TodoAPIServiceProtocol {

	private let endpoint = URL(string: "https://dummyjson.com/todos")

	func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
		guard let endpoint else {
			completion(.failure(TodoAPIError.invalidURL))
			return
		}

		let task = URLSession.shared.dataTask(with: endpoint) { data, _, error in
			if let error {
				completion(.failure(error))
				return
			}
			guard let data else {
				completion(.failure(TodoAPIError.emptyResponse))
				return
			}
			do {
				let response = try JSONDecoder().decode(
					TodoListResponseDTO.self,
					from: data
				)
				completion(.success(response.todos))
			} catch {
				completion(.failure(error))
			}
		}
		task.resume()
	}
}
