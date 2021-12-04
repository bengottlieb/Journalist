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
		
		func log() {
			if let note = note {
				print("Error \(note): \(error.localizedDescription)")
			} else {
				print("Error: \(error.localizedDescription)", separator: "")
			}
			
			print(error)
		}
	}
}
