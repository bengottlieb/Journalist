//
//  MessageCenterScreen.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct MessageCenterScreen: View {
	@State var selectedConnection: ServerConnection?
	var body: some View {
		HStack() {
			ConnectionListView(selected: $selectedConnection)
				.frame(width: 250)
			if let selected = selectedConnection {
				ConnectionHistoryView(connection: selected)
			} else {
				Spacer()
			}
		}
	}
}

struct MessageCenterScreen_Previews: PreviewProvider {
	static var previews: some View {
		MessageCenterScreen()
	}
}
