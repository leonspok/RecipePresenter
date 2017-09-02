//
//  MCCastingManager.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 31/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCCastingSessionManager {
	static let sessionType: String = "rcpcasting"
	let peer: MCPeerID = MCPeerID.init(displayName: UIDevice.current.name)
	lazy private(set) var session: MCSession = { [unowned self] in
		let session = MCSession.init(peer: self.peer, securityIdentity: nil, encryptionPreference: .none)
		return session
	}()
	lazy private(set) var browser: MCNearbyServiceBrowser = { [unowned self] in
		let browser = MCNearbyServiceBrowser.init(peer: self.peer, serviceType: MCCastingSessionManager.sessionType)
		return browser
	}()
}

class MCTargetsBrowser: NSObject, RecipeCastingTargetsBrowser, MCNearbyServiceBrowserDelegate {
	internal(set) var suggestedTarget: RecipeCastingTarget? {
		didSet {
			if let delegate = self.delegate {
				delegate.targetsBrowser(self, updated: self.suggestedTarget)
			}
		}
	}
	internal(set) var targets: [RecipeCastingTarget] = [] {
		didSet {
			self.suggestedTarget = self.targets.first(where: { (target) -> Bool in
				if let target = target as? MCCastingTarget {
					return target.type == .appletv
				} else {
					return false
				}
			})
			if let delegate = self.delegate {
				delegate.targetsBrowser(self, found: self.targets)
			}
		}
	}
	var delegate: RecipeCastingTargetsBrowserDelegate?
	
	internal let sessionManager: MCCastingSessionManager
	
	init(sessionManager: MCCastingSessionManager) {
		self.sessionManager = sessionManager
		super.init()
		self.sessionManager.browser.delegate = self
	}
	
	func startBrowsing() {
		self.sessionManager.browser.startBrowsingForPeers()
	}
	
	func stopBrowsing() {
		self.sessionManager.browser.stopBrowsingForPeers()
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		let newTarget = MCCastingTarget.init(peerID: peerID, info: info)
		for i in 0..<self.targets.count {
			guard let target = self.targets[i] as? MCCastingTarget else {
				continue
			}
			if target.uniqueID == newTarget.uniqueID {
				if target.timestamp < newTarget.timestamp {
					self.targets.remove(at: i)
					self.targets.append(newTarget)
				}
				return
			}
		}
		self.targets.append(newTarget)
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		var indexToRemove: Int? = nil
		for i in 0..<self.targets.count {
			guard let target = self.targets[i] as? MCCastingTarget else {
				continue
			}
			if target.peerID == peerID {
				indexToRemove = i
				break
			}
		}
		if let index = indexToRemove {
			self.targets.remove(at: index)
		}
	}
}

struct MCCastingTarget: RecipeCastingTarget {
	internal(set) var name: String!
	
	let type: DeviceType
	let timestamp: CFAbsoluteTime
	let uniqueID: String
	
	let peerID: MCPeerID
	
	init(peerID: MCPeerID, info: [String : String]?) {
		self.peerID = peerID
		self.name = self.peerID.displayName
		if let info = info, let typeStr: String = info["type"], let type = DeviceType.init(rawValue: typeStr) {
			self.type = type
		} else {
			self.type = .unknown
		}
		if let info = info, let timestampStr = info["timestamp"], let timestamp = CFAbsoluteTime(timestampStr) {
			self.timestamp = timestamp
		} else {
			self.timestamp = 0
		}
		if let info = info, let uniqueID = info["uid"] {
			self.uniqueID = uniqueID
		} else {
			self.uniqueID = ""
		}
	}
	
	enum DeviceType: String {
		case appletv
		case iphone
		case ipad
		case ipod
		case mac
		case unknown
	}
}

class MCCastingManager: NSObject, RecipeCastingManager, MCSessionDelegate {
	internal(set) var castingRecipe: Recipe? = nil
	internal(set) var currentTarget: RecipeCastingTarget? = nil
	internal(set) var state: RecipeCastingManagerState = .idle {
		didSet {
			if let delegate = self.delegate {
				delegate.castingManager(self, updated: self.state)
			}
		}
	}
	var delegate: RecipeCastingManagerDelegate?
	
	internal let sessionManager: MCCastingSessionManager
	
	init(sessionManager: MCCastingSessionManager) {
		self.sessionManager = sessionManager
		super.init()
		self.sessionManager.session.delegate = self
	}
	
	func beginCasting(with target: RecipeCastingTarget, recipe: Recipe) {
		if let target = target as? MCCastingTarget {
			self.currentTarget = target
			self.castingRecipe = recipe
			self.state = .waiting
			//self.send(RecipeCastingAction.start(recipe: recipe))
			self.sessionManager.browser.invitePeer(target.peerID, to: self.sessionManager.session, withContext: nil, timeout: 30)
		}
	}
	
	func endCasting() {
		self.send(.stop)
	}
	
	func send(_ action: RecipeCastingAction) {
		guard let currentTarget = self.currentTarget as? MCCastingTarget else {
			return
		}
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(action) else {
			return
		}
		try? self.sessionManager.session.send(data, toPeers: [currentTarget.peerID], with: .reliable)
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		guard let currentTarget = self.currentTarget as? MCCastingTarget else {
			return
		}
		guard currentTarget.peerID == peerID else {
			return
		}
		switch state {
		case .connecting:
			self.state = .waiting
		case .connected:
			self.state = .waiting
			if let recipe = self.castingRecipe {
				self.send(RecipeCastingAction.start(recipe: recipe))
			}
		case .notConnected:
			self.currentTarget = nil;
			self.state = .idle
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		guard let currentTarget = self.currentTarget as? MCCastingTarget else {
			return
		}
		guard currentTarget.peerID == peerID else {
			return
		}
		let decoder = JSONDecoder()
		guard let callback = try? decoder.decode(RecipeCastingCallback.self, from: data) else {
			return
		}
		
		switch callback {
		case .started:
			self.state = .casting
		default:
			break
		}
		
		if let delegate = self.delegate {
			delegate.castingManager(self, received: callback)
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
