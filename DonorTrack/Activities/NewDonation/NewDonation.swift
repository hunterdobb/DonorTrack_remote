//
//  NewDonation.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 5/2/23.
//

import Foundation

struct NewDonation {
	var startTime = Date.distantFuture.timeIntervalSince1970
	var endTime = Date.distantFuture.timeIntervalSince1970
	var donationAmount = ""
	var protein = ""
	var compensation = ""
	var notes = ""
	var state: NewDonationState = .idle

	enum NewDonationState {
		case idle, started, finished
	}
}
