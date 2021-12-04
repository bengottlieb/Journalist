//
//  Journalist.swift
//
//  Created by Ben Gottlieb on 12/4/21.
//

import Foundation

public func report(_ note: String? = nil, _ closure: @escaping () throws -> Void) {
	Task { await Journalist.instance.report(note, closure) }
}

public func report<Result>(_ note: String? = nil, _ closure: @escaping () throws -> Result) async -> Result? {
	await Journalist.instance.report(note, closure)
}

public actor Journalist {
	public static let instance = Journalist()
	public var maxReportsTracked: UInt? = 100
	public var logReports = true
	
	var reports: [Report] = []

	public func report(error: Error, _ note: String? = nil) {
		let report = Report(error, note)
		reports.append(report)
		if let max = maxReportsTracked {
			while max < reports.count {
				reports.remove(at: 0)
			}
		}
		if logReports { report.log() }
	}
	
	public func report(_ note: String? = nil, _ closure: () throws -> Void) {
		do {
			try closure()
		} catch {
			report(error: error, note)
		}
	}
	
	public func report<Result>(_ note: String? = nil, _ closure: () throws -> Result) -> Result? {
		do {
			return try closure()
		} catch {
			report(error: error, note)
			return nil
		}
	}
}


