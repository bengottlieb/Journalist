//
//  Journalist.Report.swift
//  Journalist
//
//  Created by Ben Gottlieb on 12/4/21.
//

import Foundation

extension Journalist {
	struct Report {
		let error: Error
		let note: String?
		let file: URL?
		let line: Int
		let function: String

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
