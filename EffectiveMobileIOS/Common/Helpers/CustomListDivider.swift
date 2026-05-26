// by mioe

import SwiftUI

struct CustomListDivider<Content: View>: View {

	@ViewBuilder let content: Content

	var body: some View {
		_VariadicView.Tree(CustomListDividerLayout()) {
			content
		}
	}
}

private struct CustomListDividerLayout: _VariadicView_MultiViewRoot {
	func body(children: _VariadicView.Children) -> some View {
		let last = children.last?.id

		VStack(spacing: 0) {
			ForEach(children) { child in
				child

				if child.id != last {
					VStack(spacing: 0) {
						Divider()
					}
					.frame(maxWidth: .infinity)
				}
			}
		}
	}
}
