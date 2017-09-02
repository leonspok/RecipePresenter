//
//  RecipeCastingAction.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 31/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

enum RecipeCastingAction {
	case start(recipe: Recipe)
	case moveForward
	case moveBackward
	case startTimer
	case stopTimer
	case stop
	case unknown
}

extension RecipeCastingAction: Codable {
	private enum CodingKeys: String, CodingKey {
		case action, recipe
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let actionStr = try container.decode(String.self, forKey: .action)
		switch actionStr {
		case "start":
			self = .start(recipe: try container.decode(Recipe.self, forKey: .recipe))
		case "moveForward":
			self = .moveForward
		case "moveBackward":
			self = .moveBackward
		case "startTimer":
			self = .startTimer
		case "stopTimer":
			self = .stopTimer
		case "stop":
			self = .stop
		default:
			self = .unknown
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case let .start(recipe):
			try container.encode("start", forKey: .action)
			try container.encode(recipe, forKey: .recipe)
		case .moveForward:
			try container.encode("moveForward", forKey: .action)
		case .moveBackward:
			try container.encode("moveBackward", forKey: .action)
		case .startTimer:
			try container.encode("startTimer", forKey: .action)
		case .stopTimer:
			try container.encode("stopTimer", forKey: .action)
		case .stop:
			try container.encode("stop", forKey: .action)
		default:
			break
		}
	}
}
