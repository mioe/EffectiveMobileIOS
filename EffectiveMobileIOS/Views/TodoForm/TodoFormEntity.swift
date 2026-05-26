// by mioe

import Foundation

/// режим работы модуля формы
enum TodoFormMode: Hashable {
	case create
	case edit(UUID)

	var editingId: UUID? {
		if case .edit(let id) = self { return id }
		return nil
	}
}
