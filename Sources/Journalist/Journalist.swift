//
//  Journalist.swift
//
//  Created by Ben Gottlieb on 12/4/21.
//

import Foundation

public struct UnreportedError: Error {
	public init() { }
}

public func report(_ file: @autoclosure () -> String = #file, _ line: @autoclosure () -> Int = #line, _ function: @autoclosure () -> String = #function, _ level: Journalist.Level = .loggedDev, note: @autoclosure @escaping () -> String, _ closure: @escaping () async throws -> Void) {
	let line = line()
	let function = function()
	let file = file()
	Task { await Journalist.instance.report(file, line, function, level, note, closure) }
}

public func report<Result>(_ file: @autoclosure () -> String = #file, _ line: @autoclosure () -> Int = #line, _ function: @autoclosure () -> String = #function, _ level: Journalist.Level = .loggedDev, note: @autoclosure @escaping () -> String, _ closure: @escaping () async throws -> Result) async -> Result? {
	await Journalist.instance.report(file(), line(), function(), level, note, closure)
}

public func report(_ file: @autoclosure () -> String = #file, _ line: @autoclosure () -> Int = #line, _ function: @autoclosure () -> String = #function, _ level: Journalist.Level = .loggedDev, _ closure: @escaping () async throws -> Void) {
	let line = line()
	let function = function()
	let file = file()
	Task { await Journalist.instance.report(file, line, function, level, { "" }, closure) }
}

public func report<Result>(_ file: @autoclosure () -> String = #file, _ line: @autoclosure () -> Int = #line, _ function: @autoclosure () -> String = #function, _ level: Journalist.Level = .loggedDev, _ closure: @escaping () async throws -> Result) async -> Result? {
	await Journalist.instance.report(file(), line(), function(), level, { "" }, closure)
}

public actor Journalist {
	public static let instance = Journalist()
	public var maxReportsTracked: UInt? = 100
	public var printReports = true
	
	var reports: [Report] = []

	public func report(_ file: @autoclosure () -> String = #file, _ line: @autoclosure () -> Int = #line, _ function: @autoclosure () -> String = #function, _ level: Journalist.Level = .loggedDev, error: Error, _ note: String? = nil) {
		if error is UnreportedError { return }
		let report = Report(file: file(), line: line(), function: function(), error: error, note: note)
		reports.append(report)
		if let max = maxReportsTracked {
			while max < reports.count {
				reports.remove(at: 0)
			}
		}
		if printReports { report.print() }
	}
	
	public func report(_ file: @autoclosure () -> String = #file, _ line: @autoclosure () -> Int = #line, _ function: @autoclosure () -> String = #function, _ level: Journalist.Level = .loggedDev, _ note: @escaping () -> String, _ closure: () async throws -> Void) async {
		do {
			try await closure()
		} catch {
			report(file(), line(), function(), error: error, note())
		}
	}
	
	public func report<Result>(_ file: @autoclosure () -> String = #file, _ line: @autoclosure () -> Int = #line, _ function: @autoclosure () -> String = #function, _ level: Journalist.Level = .loggedDev, _ note: @escaping () -> String, _ closure: () async throws -> Result) async -> Result? {
		do {
			return try await closure()
		} catch {
			report(file(), line(), function(), error: error, note())
			return nil
		}
	}
}


public extension Journalist {
	enum Level { case ignored, loggedDev, loggedUser, alertDev, alertUser }
}
