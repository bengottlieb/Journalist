//
//  Listener.swift
//  QuickLog
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation

import Foundation
import Network
import MultipeerConnectivity

public class Server: ObservableObject {
	public static var instance: Server!
	
	let port: NWEndpoint.Port
	let listener: NWListener
	var advertiser: MCNearbyServiceAdvertiser?
	
	var allConnections: [ServerConnection] { pastConnections + activeConnections.values.sorted() }
	var pastConnections: [ServerConnection] = []
	var hostAddress: String?
	
	public static var defaultPort: UInt16 = 8888
	private var activeConnections: [Int: ServerConnection] = [:]
	lazy var peerID = generateLocalPeerID()
	
	public static func start(at port: UInt16 = Server.defaultPort) throws {
		if let current = instance {
			if current.port.rawValue == port { return }			// already running
			
			current.stop()
		}
		
		instance = Server(port: port)
		try instance.start()
	}
	
	init(port: UInt16) {
		self.port = NWEndpoint.Port(rawValue: port)!
		listener = try! NWListener(using: .tcp, on: self.port)
		hostAddress = hostAddresses().first
	}
	
	func start() throws {
		print("Server starting...")
		listener.stateUpdateHandler = self.stateDidChange(to:)
		listener.newConnectionHandler = self.didAccept(nwConnection:)
		listener.start(queue: .main)
	}
	
	func stateDidChange(to newState: NWListener.State) {
		switch newState {
		case .ready:
			print("Server ready.")
		case .failed(let error):
			print("Server failure, error: \(error)")
			exit(EXIT_FAILURE)
		default:
			break
		}
	}
	
	private func didAccept(nwConnection: NWConnection) {
		let connection = ServerConnection(nwConnection: nwConnection)
		self.activeConnections[connection.id] = connection
		connection.start()
		DispatchQueue.main.async { self.objectWillChange.send() }
	}
	
	func remove(connection: ServerConnection) {
		if let index = pastConnections.firstIndex(of: connection) {
			pastConnections.remove(at: index)
			DispatchQueue.main.async { self.objectWillChange.send() }
		}
	}
	
	func connectionDidStop(_ connection: ServerConnection) {
		guard activeConnections[connection.id] != nil else { return }
		pastConnections.append(connection)
		self.activeConnections.removeValue(forKey: connection.id)
		print("server did close connection \(connection.id)")
		DispatchQueue.main.async { self.objectWillChange.send() }
	}
	
	private func stop() {
		self.listener.stateUpdateHandler = nil
		self.listener.newConnectionHandler = nil
		self.listener.cancel()
		pastConnections += activeConnections.values
		self.activeConnections.removeAll()
		DispatchQueue.main.async { self.objectWillChange.send() }
	}
}
