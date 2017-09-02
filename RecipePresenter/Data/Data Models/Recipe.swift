//
//  Recipe.swift
//  RecipePresenter
//
//  Created by Игорь Савельев on 30/08/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import Foundation

struct Recipe: Identifiable, Codable {
	var uid: GenericIdentifier<Recipe>?
	var hashValue: Int {
		guard let uid = self.uid else {
			return -1
		}
		return uid.hashValue;
	}
	
	let title: String!
	let description: String?
	let previewImageURL: String?
	
	let ingredients: [Ingredient]!
	let instruments: [Instrument]!
	let steps: [Step]!
	
	struct Ingredient: Codable {
		let name: String!
		let amount: Amount
		
		enum Amount {
			case indefinite(tip: String?)
			case definite(amount: Double, unit: String?)
		}
	}
	
	struct Instrument: Codable {
		let name: String!
		let amount: NSInteger
	}
	
	struct Step: Codable {
		enum CodingKeys: String, CodingKey {
			case type = "additionalData"
			case shortDescription
			case fullDescription
			case ingredients
			case instruments
		}
		
		let type: StepType
		let shortDescription: String?
		let fullDescription: String!
		
		let ingredients: [Ingredient]!
		let instruments: [Instrument]!
		
		enum StepType {
			case simple
			case withPhoto(photoURL: URL)
			case withVideo(videoURL: URL)
			case withTimer(duration: TimeInterval)
		}
	}
}

//MARK: Codable

extension GenericIdentifier: Codable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self.rawValue = try container.decode(String.self)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.rawValue)
	}
}

extension Recipe.Ingredient.Amount: Codable {
	private enum CodingKeys: String, CodingKey {
		case tip, amount, unit
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let amount = try container.decodeIfPresent(Double.self, forKey: .amount) {
			self = .definite(amount: amount, unit: try container.decodeIfPresent(String.self, forKey: .unit))
		} else {
			self = .indefinite(tip: try container.decodeIfPresent(String.self, forKey: .tip))
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case let .indefinite(tip: tip):
			try container.encode(tip, forKey: .tip)
		case let .definite(amount: amount, unit: unit):
			try container.encode(amount, forKey: .amount)
			try container.encode(unit, forKey: .unit)
		}
	}
}

extension Recipe.Step.StepType: Codable {
	private enum CodingKeys: String, CodingKey {
		case photoURL, videoURL, duration
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let url = try container.decodeIfPresent(URL.self, forKey: .photoURL) {
			self = .withPhoto(photoURL: url)
		} else if let url = try container.decodeIfPresent(URL.self, forKey: .videoURL) {
			self = .withVideo(videoURL: url)
		} else if let duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) {
			self = .withTimer(duration: duration)
		} else {
			self = .simple
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case let .withVideo(videoURL: url):
			try container.encode(url, forKey: .photoURL)
		case let .withPhoto(photoURL: url):
			try container.encode(url, forKey: .videoURL)
		case let .withTimer(duration: duration):
			try container.encode(duration, forKey: .duration)
		default:
			break;
		}
	}
}
