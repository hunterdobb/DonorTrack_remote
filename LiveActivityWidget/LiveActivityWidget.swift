//
//  LiveActivityWidget.swift
//  LiveActivityWidget
//
//  Created by Hunter Dobbelmann on 4/4/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivityWidget: Widget {
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: NewDonationAttributes.self) { context in
			// Live Activity
			LiveActivityWidgetView(context: context)
		} dynamicIsland: { context in
			DynamicIsland {
				DynamicIslandExpandedRegion(.leading) {
					Label {
						Text("\(context.state.cycleCount)")
							.bold()
					} icon: {
						Image(systemName: "repeat")
							.font(.headline)
					}
					.padding()
					.lineLimit(1)
					.minimumScaleFactor(0.8)
					.font(.headline)
					.foregroundStyle(.yellow)
					.fontDesign(.rounded)
					.background(.indigo.gradient, in: Capsule(style: .continuous))
				}

				DynamicIslandExpandedRegion(.trailing) {
					Label {
						Text(context.state.startTime, style: .timer)
							.bold()
					} icon: {
						Image(systemName: "timer")
							.font(.headline)
					}
					.padding()
					.lineLimit(1)
					.minimumScaleFactor(0.5)
					.foregroundStyle(.yellow)
					.fontDesign(.rounded)
					.bold()
					.monospacedDigit()
					.background(.indigo.gradient, in: Capsule(style: .continuous))
				}

				DynamicIslandExpandedRegion(.center) {

				}

				DynamicIslandExpandedRegion(.bottom) {
					Text("Start: \(context.state.startTime, style: .time)")
						.bold()
						.fontDesign(.rounded)
				}
			} compactLeading: {
				IconView(context: context)
			} compactTrailing: {
				CompactTimerView(context: context)
			} minimal: {
				IconView(context: context)
			}
		}
	}
}

struct IconView: View {
	let context: ActivityViewContext<NewDonationAttributes>

	var cycleString: String {
		String(context.state.cycleCount)
	}

	var body: some View {
		Image(systemName: "\(cycleString).circle.fill")
			.resizable()
			.frame(width: 25, height: 25)
			.symbolRenderingMode(.palette)
			.foregroundStyle(.yellow.gradient, .indigo.gradient)
	}
}

struct CompactTimerView: View {
	let context: ActivityViewContext<NewDonationAttributes>

	var body: some View {
		Text(context.state.startTime, style: .timer)
			.multilineTextAlignment(.center)
			.foregroundStyle(.yellow)
			.bold()
			.frame(width: 45)
			.monospacedDigit()
	}
}

// MARK: - Live Activity
struct LiveActivityWidgetView: View {
	let context: ActivityViewContext<NewDonationAttributes>

	var body: some View {
		HStack(alignment: .center) {
			VStack(alignment: .leading) {
				Text("Start: \(context.state.startTime, style: .time)")
					.foregroundColor(.white)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
					.font(.title)
					.bold()

				Label {
					Text("\(context.state.cycleCount)")
						.bold()
				} icon: {
					Image(systemName: "repeat")
						.font(.headline)
				}
				.font(.title2)
				.bold()
				.foregroundStyle(.yellow)
				.fontDesign(.rounded)
			}
			.padding([.leading, .top, .bottom])

			Spacer()

			Text(context.state.startTime, style: .timer)
				.font(.title)
				.bold()
				.fontDesign(.rounded)
				.monospacedDigit()
				.foregroundStyle(.yellow)
				.multilineTextAlignment(.trailing)
				.padding()
				.activityBackgroundTint(.indigo.opacity(0.8))
		}

//		VStack(alignment: .center) {
//			HStack(alignment: .firstTextBaseline) {
//				Label {
//					Text("\(context.state.cycleCount)")
//						.bold()
//				} icon: {
//					Image(systemName: "repeat")
//						.font(.headline)
//				}
//				.font(.title)
//				.bold()
//				//.padding(.leading)
//				.foregroundStyle(.yellow)
//				.fontDesign(.rounded)
//
//				Spacer()
//
//				Text(context.state.startTime, style: .timer)
//					.font(.title)
//					.bold()
//					.fontDesign(.rounded)
//					.monospacedDigit()
//					.foregroundStyle(.yellow)
//					.multilineTextAlignment(.trailing)
//					//.padding(.trailing)
//					.activityBackgroundTint(.indigo.opacity(0.8))
//			}
//
//			Text("Started: \(context.state.startTime, style: .time)")
//				.foregroundColor(.white)
//				.fontDesign(.rounded)
//				.font(.title2)
//				.bold()
//				.padding(.top, 1)
//		}
//		.padding()
	}
}
