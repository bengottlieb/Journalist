//
//  ConnectionListRow.swift
//  Viewer_macOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct ConnectionListRow: View {
	@ObservedObject var connection: ServerConnection
	@Binding var selected: ServerConnection?
	var body: some View {
		HStack() {
			VStack() {
				Text("Connection #\(connection.id)")
				Text(connection.receivedMessages.last ?? "--")
					.foregroundColor(Color(.secondaryLabelColor))
			}
			.opacity(connection.isConnected ? 1 : 0.25)
			Spacer()
			Button(action: {
				if connection.isConnected {
					connection.close()
				} else {
					Server.instance.remove(connection: connection)
				}
			}) {
				Text(connection.isConnected ? "❌" : "🗑")
					.padding()
			}
			.buttonStyle(PlainButtonStyle())
		}
		.background(selected == connection ? Color.gray : Color.white)
		.onTapGesture {
			selected = connection
		}
	}
}

