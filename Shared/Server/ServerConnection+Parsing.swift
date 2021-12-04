//
//  ServerConnection+Parsing.swift
//  Viewer_macOS
//
//  Created by Ben Gottlieb on 8/23/21.
//

import Foundation

extension ServerConnection {
	static let leftBracket = "[".data(using: .utf8)!
	static let rightBracket = "]".data(using: .utf8)!
	
	func parse(data: Data) {
		let raw = Self.leftBracket + data + Self.rightBracket
		
		do {
			guard let json = try JSONSerialization.jsonObject(with: raw, options: [.fragmentsAllowed]) as? [Any] else {
				print("Unable to parse: \(String(data: data, encoding: .utf8) ?? "some data")")
				return
			}
			
			for item in json {
				if let string = item as? String {
					receivedMessages.append(string)
				} else if let dict = item as? [String: Any], let kind = dict["kind"] as? String {
					print("Got: \(kind)")
				} else {
					print("Unable to parse: \(item)")
				}
			}
		} catch {
			print("Unable to parse: \(String(data: data, encoding: .utf8) ?? "some data"), \n\(error)")
		}
		DispatchQueue.main.async { self.objectWillChange.send() }
	}
}
