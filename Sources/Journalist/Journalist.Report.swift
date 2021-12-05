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

		init(_ error: Error, _ note: String?) {
			self.error = error
			self.note = note
		}
		
		func print() {
			if let note = note {
				Swift.print("Error \(note): \(error.localizedDescription)")
			} else {
				Swift.print("Error: \(error.localizedDescription)", separator: "")
			}
			
			Swift.print(error)
		}
	}
}
