//
//  Journalist.swift
//
//  Created by Ben Gottlieb on 12/4/21.
//

import Foundation

public struct UnreportedError: Error {
	public init() { }
}

public func report(_ level: Journalist.Level = .loggedDev, note: @autoclosure @escaping () -> String, _ closure: @escaping () async throws -> Void) {
	Task { await Journalist.instance.report(level, note, closure) }
}

public func report<Result>(_ level: Journalist.Level = .loggedDev, note: @autoclosure @escaping () -> String, _ closure: @escaping () async throws -> Result) async -> Result? {
	await Journalist.instance.report(level, note, closure)
}

public func report(_ level: Journalist.Level = .loggedDev, _ closure: @escaping () async throws -> Void) {
	Task { await Journalist.instance.report(level, { "" }, closure) }
}

public func report<Result>(_ level: Journalist.Level = .loggedDev, _ closure: @escaping () async throws -> Result) async -> Result? {
	await Journalist.instance.report(level, { "" }, closure)
}

public actor Journalist {
	public static let instance = Journalist()
	public var maxReportsTracked: UInt? = 100
	public var printReports = true
	
	var reports: [Report] = []

	public func report(_ level: Journalist.Level = .loggedDev, error: Error, _ note: String? = nil) {
		if error is UnreportedError { return }
		let report = Report(error, note)
		reports.append(report)
		if let max = maxReportsTracked {
			while max < reports.count {
				reports.remove(at: 0)
			}
		}
		if printReports { report.print() }
	}
	
	public func report(_ level: Journalist.Level = .loggedDev, _ note: @escaping () -> String, _ closure: () async throws -> Void) async {
		do {
			try await closure()
		} catch {
			report(error: error, note())
		}
	}
	
	public func report<Result>(_ level: Journalist.Level = .loggedDev, _ note: @escaping () -> String, _ closure: () async throws -> Result) async -> Result? {
		do {
			return try await closure()
		} catch {
			report(error: error, note())
			return nil
		}
	}
}


public extension Journalist {
	enum Level { case ignored, loggedDev, loggedUser, alertDev, alertUser }
}
