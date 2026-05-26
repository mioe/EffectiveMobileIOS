// by mioe

import SwiftUI

struct AboutMe: View {

	var body: some View {
		VStack(spacing: 16) {
			Image(._1775640178368)
				.resizable()
				.scaledToFill()
				.frame(width: 80, height: 80)
				.clipShape(.circle)

			Text(
				"""
				I specialize in Vue 3/Astro, TypeScript, Nest/Hono, and PostgreSQL. I build products from scratch and scale existing ones - from frontend architecture to CI/CD and billing systems. I know how to hire, mentor, and grow developers within a team.

				In my free time, I follow IT news, explore new technologies, and try applying them in personal projects. I'm also really eager to become an iOS developer.

				🐥🐥🐤
				"""
			)
			.font(.system(size: 14))
			.multilineTextAlignment(.center)

			VStack(alignment: .leading, spacing: 12) {
				Link(destination: URL(string: "https://mioe.github.io")!) {
					HStack {
						Image(.iGlobal)
							.resizable()
							.scaledToFill()
							.frame(width: 14, height: 14)
						Text("mioe.github.io")
							.font(.system(size: 14))
					}
				}

				Link(
					destination: URL(
						string: "https://github.com/mioe/EffectiveMobileIOS"
					)!
				) {
					HStack {
						Image(.iClipboard)
							.resizable()
							.scaledToFill()
							.frame(width: 14, height: 14)
						Text("Source")
							.font(.system(size: 14))
					}
				}
			}
			.foregroundStyle(.blue)
			
			Text("2026-05-26 at 08.29.59 PM")
				.font(.system(size: 12))
				.foregroundStyle(.secondary)
				.padding(.top, 32)
		}
		.padding(.horizontal, 20)
	}
}
