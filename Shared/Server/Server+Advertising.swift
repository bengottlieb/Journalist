//
//  Server+Advertising.swift
//  Viewer_macOS
//
//  Created by Ben Gottlieb on 8/23/21.
//

import Foundation
import MultipeerConnectivity

extension Server {
	static let serviceType = "SAI-SimpleLog"
	public func advertise() {
		if let address = hostAddress {
			advertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: ["host": address, "port": "\(port)"], serviceType: Self.serviceType)
			advertiser?.startAdvertisingPeer()
		} else {
			print("Failed to advertise, no address available")
		}
	}
	
	func generateLocalPeerID() -> MCPeerID {
		MCPeerID(displayName: Host.current().localizedName ?? "My Mac")
	}


	func hostAddresses() -> [String] {
	 var addrList : UnsafeMutablePointer<ifaddrs>?
	 guard getifaddrs(&addrList) == 0, let firstAddr = addrList else { return [] }
	 defer { freeifaddrs(addrList) }
	 var results: [String] = []
	 for cursor in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
		 let interfaceName = String(cString: cursor.pointee.ifa_name)
		 if !interfaceName.hasPrefix("en") { continue }
		 let addrStr: String
		 var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
		 if
			 let addr = cursor.pointee.ifa_addr,
			 getnameinfo(addr, socklen_t(addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0,
			 hostname[0] != 0
		 {
			 addrStr = String(cString: hostname)
		 } else {
			 addrStr = "?"
		 }
		 if addrStr.filter({ $0 == "." }).count == 3 { results.append(addrStr) }
	 }
	 return results
 }
}

