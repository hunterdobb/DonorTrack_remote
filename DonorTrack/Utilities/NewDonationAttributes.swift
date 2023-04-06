//
//  NewDonationAttributes.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 4/4/23.
//

import ActivityKit
import Foundation

struct NewDonationAttributes: ActivityAttributes {
	public typealias NewDonationStatus = ContentState

	public struct ContentState: Codable, Hashable {
		var startTime: Date
		var cycleCount: Int16
	}
}
