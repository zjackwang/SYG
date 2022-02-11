//
//  EndPointModel.swift
//  HTTPManagerTests
//
//  Created by Jack Wang on 2/11/22.
//

import Foundation

struct EndPointModel: Codable, Equatable {
    var status: String?
    var data : [String: String]?
    
    private enum CodingKeys: String, CodingKey {
        case status
        case data
    }
    
    static func == (lhs: EndPointModel, rhs: EndPointModel) -> Bool {
        return lhs.status == rhs.status
    }
}
