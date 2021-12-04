//
//  ConnectionHistoryView.swift
//  Viewer_macOS
//
//  Created by Ben Gottlieb on 8/23/21.
//

import SwiftUI

struct ConnectionHistoryView: View {
	@ObservedObject var connection: ServerConnection
	
	var body: some View {
		ScrollView() {
			LazyVStack() {
				ForEach(connection.receivedMessages.indices, id: \.self) { idx in
					let message = connection.receivedMessages[idx]
					HStack() {
						Text(message)
						Spacer()
					}
					.font(.system(size: 12, weight: .regular, design: .monospaced))
				}
			}
		}
	}
}
