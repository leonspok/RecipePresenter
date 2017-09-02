//
//  RecipeCastingCallback.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 31/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

enum RecipeCastingCallback {
	case started
	case stepChanged(index: UInt)
	case timerStarted
	case timerStopped
	case finished
	case unknown
}

extension RecipeCastingCallback: Codable {
	private enum CodingKeys: String, CodingKey {
		case callback, index
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let actionStr = try container.decode(String.self, forKey: .callback)
		switch actionStr {
		case "started":
			self = .started
		case "stepChanged":
			self = .stepChanged(index: try container.decode(UInt.self, forKey: .index))
		case "timerStarted":
			self = .timerStarted
		case "timerStopped":
			self = .timerStopped
		case "finished":
			self = .finished
		default:
			self = .unknown
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .started:
			try container.encode("started", forKey: .callback)
		case let .stepChanged(index: index):
			try container.encode("stepChanged", forKey: .callback)
			try container.encode(index, forKey: .index)
		case .timerStarted:
			try container.encode("timerStarted", forKey: .callback)
		case .timerStopped:
			try container.encode("timerStopped", forKey: .callback)
		case .finished:
			try container.encode("finished", forKey: .callback)
		default:
			break
		}
	}
}
