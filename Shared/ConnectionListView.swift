//
//  ConnectionListView.swift
//  Viewer_macOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct ConnectionListView: View {
	@Binding var selected: ServerConnection?
	@ObservedObject var server = Server.instance
    var body: some View {
		ScrollView() {
			LazyVStack() {
				ForEach(server.allConnections) { connection in
					ConnectionListRow(connection: connection, selected: $selected)
				}
			}
		}
	}
}
