// by mioe

import SwiftUI

struct DateFormatedText: View {
	
	let date: Date
	
	var body: some View {
		Text(date, format: Date.VerbatimFormatStyle(
			format: "\(day: .twoDigits)/\(month: .twoDigits)/\(year: .twoDigits)",
			timeZone: .current,
			calendar: .current
		))
	}
}
