//
//  analyzedReceipt.swift
//  sYg
//
//  Created by Jack Wang on 1/3/22.
//

import Foundation

/*
 * JSON Response
 *  sample: https://github.com/Azure-Samples/cognitive-services-REST-api-samples/blob/master/curl/form-recognizer/receipt-result.json
 */
struct AnalyzedReceipt: Codable {
    let status: String
    let createdDateTime: String
    let lastUpdatedDateTime: String
    let analyzeResult: AnalyzeResult?
    
    private enum CodingKeys: String, CodingKey {
        case status, createdDateTime, lastUpdatedDateTime, analyzeResult
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.status = try container.decode(String.self, forKey: .status)
        self.createdDateTime = try container.decode(String.self, forKey: .createdDateTime)
        self.lastUpdatedDateTime = try container.decode(String.self, forKey: .lastUpdatedDateTime)
        self.analyzeResult = try container.decodeIfPresent(AnalyzeResult.self, forKey: .analyzeResult)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(status, forKey: .status)
        try container.encode(createdDateTime, forKey: .createdDateTime)
        try container.encode(lastUpdatedDateTime, forKey: .lastUpdatedDateTime)
        try container.encodeIfPresent(analyzeResult, forKey: .analyzeResult)
    }
}
