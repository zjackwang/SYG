//
//  AnalyzeResult.swift
//  sYg
//
//  Created by Jack Wang on 1/4/22.
//

import Foundation

struct AnalyzeResult: Codable {
    let version: String
    let readResults: [ReadResult]
    let documentResults: [DocumentResult]
    
    private enum CodingKeys: String, CodingKey {
        case version, readResults, documentResults
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.version = try container.decode(String.self, forKey: .version)
        self.readResults = try container.decode([ReadResult].self, forKey: .readResults)
        self.documentResults = try container.decode([DocumentResult].self, forKey: .documentResults)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(version, forKey: .version)
        try container.encode(readResults, forKey: .readResults)
        try container.encode(documentResults, forKey: .documentResults)
    }
}

struct ReadResult: Codable {
    let page: Int
    let angle: Double
    let width: Int
    let height: Int
    let unit: String
    let language: String?
}
