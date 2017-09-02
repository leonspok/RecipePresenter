//
//  MultipeerConnectivityReceiving.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 01/09/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCPresentingSessionManager {
	static let sessionType: String = "rcpcasting"
	let peer: MCPeerID = MCPeerID.init(displayName: UIDevice.current.name)
	lazy private(set) var session: MCSession = { [unowned self] in
		let session = MCSession.init(peer: self.peer, securityIdentity: nil, encryptionPreference: .none)
		return session
	}()
	lazy private(set) var discoveryInfo: [String : String] = {
		var discoveryInfo: [String : String] = [:]
		#if os(iOS)
			discoveryInfo["type"] = "iphone"
		#elseif os(tvOS)
			discoveryInfo["type"] = "appletv"
		#elseif os(OSX)
			discoveryInfo["type"] = "mac"
		#else
			discoveryInfo["type"] = "unknown"
		#endif
		discoveryInfo["timestamp"] = "\(CFAbsoluteTimeGetCurrent())"
		if let uid = UIDevice.current.identifierForVendor {
			discoveryInfo["uid"] = uid.uuidString
		} else {
			discoveryInfo["uid"] = UUID.init().uuidString
		}
		return discoveryInfo
	}()
	lazy private(set) var advertiser: MCNearbyServiceAdvertiser = { [unowned self] in
 		return MCNearbyServiceAdvertiser.init(peer: self.peer, discoveryInfo: self.discoveryInfo, serviceType: MCPresentingSessionManager.sessionType)
	}()
}

struct MCPresentingSource: RecipePresentingSource {
	internal(set) var name: String!
	
	fileprivate let peerID: MCPeerID
	
	init(peerID: MCPeerID) {
		self.peerID = peerID
		self.name = peerID.displayName
	}
}

class MCPresentingAdvertiser: NSObject, RecipePresentingAdvertiser, MCNearbyServiceAdvertiserDelegate {
	var delegate: RecipePresentingAdvertiserDelegate?
	
	internal let sessionManager: MCPresentingSessionManager
	
	init(sessionManager: MCPresentingSessionManager) {
		self.sessionManager = sessionManager
		super.init()
		self.sessionManager.advertiser.delegate = self
	}
	
	func startAdvertising() {
		self.sessionManager.advertiser.startAdvertisingPeer()
	}
	
	func stopAdvertising() {
		self.sessionManager.advertiser.stopAdvertisingPeer()
	}
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		if let delegate = self.delegate {
			let source = MCPresentingSource.init(peerID: peerID)
			delegate.advertiser(self, receivedInviteFrom: source, response: { (accepted) in
				if accepted {
					invitationHandler(accepted, self.sessionManager.session)
					if let delegate = self.delegate {
						delegate.advertiser(self, successfullyInvitedFrom: source)
					}
				} else {
					invitationHandler(accepted, nil)
				}
			})
		}
	}
}

class MCPresentingManager: NSObject, RecipePresentingManager, MCSessionDelegate {
	internal(set) var presentingRecipe: Recipe?
	internal(set) var source: RecipePresentingSource
	internal(set) var delegate: RecipePresentingManagerDelegate?
	
	internal let sessionManager: MCPresentingSessionManager
	
	init(sessionManager: MCPresentingSessionManager, source: MCPresentingSource) {
		self.sessionManager = sessionManager;
		self.source = source
		super.init()
		self.sessionManager.session.delegate = self
	}
	
	func disconnect() {
		self.sessionManager.session.disconnect()
	}
	
	func send(_ callback: RecipeCastingCallback) {
		guard let source = self.source as? MCPresentingSource else {
			return
		}
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(callback) else {
			return
		}
		try? self.sessionManager.session.send(data, toPeers: [source.peerID], with: .reliable)
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		guard let source = self.source as? MCPresentingSource else {
			return
		}
		guard source.peerID == peerID else {
			return
		}
		
		switch state {
		case .notConnected:
			if let delegate = self.delegate {
				delegate.lostConnection(self)
			}
		default:
			break
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		guard let source = self.source as? MCPresentingSource else {
			return
		}
		guard source.peerID == peerID else {
			return
		}
		let decoder = JSONDecoder()
		guard let action = try? decoder.decode(RecipeCastingAction.self, from: data) else {
			return
		}
		
		if let delegate = self.delegate {
			delegate.presentingManager(self, received: action)
		}
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		//nothing to do
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		//nothing to do
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		//nothing to do
	}
}
