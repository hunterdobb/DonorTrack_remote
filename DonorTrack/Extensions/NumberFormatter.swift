//
//  NumberFormatter.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 4/9/24.
//

import Foundation

extension NumberFormatter {
	static var currency: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 0
		formatter.currencySymbol = Locale.current.currencySymbol ?? ""
		return formatter
	}
}
