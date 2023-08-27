//
//  Journalist.swift
//
//  Created by Ben Gottlieb on 12/4/21.
//

import Foundation
import OSLog

public struct UnreportedError: Error {
	public init() { }
}

public func report(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, _ note: @autoclosure @escaping () -> String, _ closure: @escaping () async throws -> Void) {
	let line = line()
	let function = function()
	let file = file()
    Task { await Journalist.instance.report(file: file, line: line, function: function, level: level, note(), closure) }
}

public func report<Result>(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, _ note: @autoclosure @escaping () -> String, _ closure: @escaping () throws -> Result) -> Result? {

	do {
		return try closure()
	} catch {
		let line = line()
		let function = function()
		let file = file()

		Task { await Journalist.instance.report(file: file, line: line, function: function, level: level, error: error, note()) }
		return nil
	}
}

public func report<Result>(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, _ note: @autoclosure @escaping () -> String, _ closure: @escaping () async throws -> Result) async -> Result? {
	try? await Journalist.instance.report(file: file(), line: line(), function: function(), level: level, note(), closure)
}

public func report(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, _ closure: @escaping () throws -> Void) {
	let line = line()
	let function = function()
	let file = file()
	do {
		try closure()
	} catch {
		Task { await Journalist.instance.report(file: file, line: line, function: function, level: level, error: error, "") }
	}
}

public func report<Result>(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, _ closure: @escaping () async throws -> Result) async throws -> Result {
	 try await Journalist.instance.report(file: file(), line: line(), function: function(), level: level, { "" }(), closure)
}

public func asyncReport<Result>(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, priority: TaskPriority? = nil, _ closure: @escaping () async throws -> Result) {
	let line = line()
	let function = function()
	let file = file()

	if let priority {
		Task.detached(priority: priority) {
			try? await Journalist.instance.report(file: file, line: line, function: function, level: level, { "" }(), closure)
		}
	} else {
		Task {
			try? await Journalist.instance.report(file: file, line: line, function: function, level: level, { "" }(), closure)
		}
	}
}

public actor Journalist {
	public static let instance = Journalist()
	public var maxReportsTracked: UInt? = 100
	public var printReports = true
	public var logger = Logger(subsystem: "journalist", category: "reports")
	
	var additionalReporter: ((Report) -> Void)?
	
	var reports: [Report] = []

    public func setAdditionalReporter(_ reporter: ((Report) -> Void)?) {
        self.additionalReporter = reporter
    }
    
	public func report(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, error: Error, _ note: String? = nil) {
		if error is UnreportedError { return }
		let report = Report(file: file(), line: line(), function: function(), error: error, note: note, logger: logger)
        additionalReporter?(report)
		reports.append(report)
		if let max = maxReportsTracked {
			while max < reports.count {
				reports.remove(at: 0)
			}
		}
		if printReports { report.print() }
	}
	
	public func report(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, _ note: @autoclosure @escaping () -> String, _ closure: () async throws -> Void) async {
		do {
			try await closure()
		} catch {
			report(file: file(), line: line(), function: function(), error: error, note())
		}
	}
	
	public func report(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, _ note: @autoclosure @escaping () -> String, _ closure: () throws -> Void) {
		do {
			try closure()
		} catch {
			report(file: file(), line: line(), function: function(), error: error, note())
		}
	}
	
	public func report<Result>(file: @autoclosure () -> String = #file, line: @autoclosure () -> Int = #line, function: @autoclosure () -> String = #function, level: Journalist.Level = .loggedDev, _ note: @autoclosure @escaping () -> String, _ closure: () async throws -> Result) async throws -> Result {
		do {
			return try await closure()
		} catch {
			report(file: file(), line: line(), function: function(), error: error, note())
			throw error
		}
	}
}


public extension Journalist {
	enum Level { case ignored, loggedDev, loggedUser, alertDev, alertUser }
}
