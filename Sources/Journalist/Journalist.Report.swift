//
//  Journalist.Report.swift
//  Journalist
//
//  Created by Ben Gottlieb on 12/4/21.
//

import Foundation
import OSLog

extension Journalist {
	public struct Report {
		public let error: Error
		public let note: String?
		public let file: URL?
		public let line: Int
		public let function: String
		let logger: Logger
		
		public var title: String { note ?? fileLineAndFunction }
		
		init(file: String, line: Int, function: String, error: Error, note: String?, logger: Logger) {
			self.error = error
			self.note = note
			self.file = URL(fileURLWithPath: file)
			self.line = line
			self.function = function
			self.logger = logger
		}
		
		var fileLineAndFunction: String {
			if let file = file {
				return file.lastPathComponent + ":\(line) \(function)"
			} else if !function.isEmpty {
				return function
			} else {
				return ""
			}
		}
		
		
		func print() {
			let message: String
			if let note = note {
				message = "[\(fileLineAndFunction)]: Error \(note): \(error.localizedDescription)"
			} else {
				message = "\(fileLineAndFunction): Error: \(error.localizedDescription)"
			}
			
			logger.info("\(message): \(error)")
		}
	}
}
