//
//  Journalist.Report.swift
//  Journalist
//
//  Created by Ben Gottlieb on 12/4/21.
//

import Foundation

extension Journalist {
	public struct Report {
        public let error: Error
        public let note: String?
        public let file: URL?
        public let line: Int
        public let function: String

        public var title: String { note ?? fileLineAndFunction }
        
		init(file: String, line: Int, function: String, error: Error, note: String?) {
			self.error = error
			self.note = note
			self.file = URL(fileURLWithPath: file)
			self.line = line
			self.function = function
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
			if let note = note {
				Swift.print("[\(fileLineAndFunction)]: Error \(note): \(error.localizedDescription)")
			} else {
				Swift.print("\(fileLineAndFunction): Error: \(error.localizedDescription)", separator: "")
			}
			
			Swift.print(error)
		}
	}
}
