//
//  DocumentResults.swift
//  sYg
//
//  Created by Jack Wang on 1/4/22.
//

import Foundation

struct DocumentResult: Codable {
    let docType: String
    let pageRange: [Int]
    var fields: [String: Field]
    
    private enum CodingKeys: String, CodingKey {
        case docType, pageRange, fields
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.docType = try container.decode(String.self, forKey: .docType)
        self.pageRange = try container.decode([Int].self, forKey: .pageRange)
        self.fields = try container.decode([String: Field].self, forKey: .fields)

        // Set all field types
        let metadata = ["ReceiptType", "MerchantName", "MerchantAddress", "MerchantPhoneNumber", "TransactionDate", "TransactionTime"]
        let purchaseInfo = ["Items", "Subtotal", "Tax", "Tip", "Total"]
        
        for key in self.fields.keys {
            if metadata.contains(key) {
                self.fields[key]?.fieldType = .Metadata
            } else if purchaseInfo.contains(key) {
                self.fields[key]?.fieldType = .PurchaseInfo
            } else {
                self.fields[key]?.fieldType = .Other
            }
        }

    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(docType, forKey: .docType)
        try container.encode(pageRange, forKey: .pageRange)
        try container.encode(fields, forKey: .fields)
    }
}

/*
 * FieldTypes:
 * 1. Metadata
 *   - ReceiptType
 *   - Merchant Name
 *   - Merchant Address
 *   - Merchant Phone Number
 *   - Transaction Date
 *   - Transaction Time
 * 2. Purchase Info
 *   - List of Items
 *   - Subtotal
 *   - Tax
 *   - Tip
 *   - Total
 * 3. Item
 *   - Quantity
 *   - Name
 *   - TotalPrice (Price)
 *
 */

struct Field: Codable {
    enum FieldType {
        case Metadata
        case PurchaseInfo
        case Item
        case Other
    }
    
    var fieldType: FieldType?
    
    // All
    let type: String
    
    // All except for Items
    let confidence: Double?
    
    // All except for ReceiptType
    let text: String?
    let boundingBox: [Double]?
    let page: Int?
    
    let valueString: String?        // ReceiptType, MerchantName, MerchantAddress
    let valuePhoneNumber: String?   // MerchantPhoneNumber
    let valueDate: String?          // TransactionDate
    let valueTime: String?          // TransactionTime
    let valueArray: [AnalyzedItem]? // Items
    let valueNumber: Double?        // SubTotal, Tax, Tip, Total
    
    private enum CodingKeys: String, CodingKey {
        case type, confidence, text, boundingBox, page,
        valueString, valuePhoneNumber, valueDate, valueTime, valueArray, valueNumber
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = try container.decode(String.self, forKey: .type)
        
        self.confidence = try container.decodeIfPresent(Double.self, forKey: .confidence)
        
        self.text = try (container.decodeIfPresent(String.self, forKey: .type))
        self.boundingBox = try (container.decodeIfPresent([Double].self, forKey: .boundingBox))
        self.page = try (container.decodeIfPresent(Int.self, forKey: .page))
        
        self.valueString = try (container.decodeIfPresent(String.self, forKey: .valueString))
        self.valuePhoneNumber = try (container.decodeIfPresent(String.self, forKey: .valuePhoneNumber))
        self.valueDate = try (container.decodeIfPresent(String.self, forKey: .valueDate))
        self.valueTime = try (container.decodeIfPresent(String.self, forKey: .valueTime))
        self.valueArray = try (container.decodeIfPresent([AnalyzedItem].self, forKey: .valueArray))
        self.valueNumber = try (container.decodeIfPresent(Double.self, forKey: .valueNumber))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(confidence, forKey: .confidence)

        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(boundingBox, forKey: .boundingBox)
        try container.encodeIfPresent(page, forKey: .page)
        
        try container.encodeIfPresent(valueString, forKey: .valueString)
        try container.encodeIfPresent(valueString, forKey: .valuePhoneNumber)
        try container.encodeIfPresent(valueDate, forKey: .valueDate)
        try container.encodeIfPresent(valueTime, forKey: .valueTime)
        try container.encodeIfPresent(valueArray, forKey: .valueArray)
        try container.encodeIfPresent(valueNumber, forKey: .valueNumber)
    }
}

// Actual purchased items
struct AnalyzedItem: Codable {
    let type: String                 // Type is object
    var valueObject: [String: Field] // Quantity -> valueNumber, name -> valueString, TotalPrice -> valueNumber
    
    private enum CodingKeys: String, CodingKey {
        case type, valueObject
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = try container.decode(String.self, forKey: .type)
        self.valueObject = try container.decode([String: Field].self, forKey: .valueObject)
        
        self.valueObject["Quantity"]?.fieldType = .Item
        self.valueObject["Name"]?.fieldType = .Item
        self.valueObject["TotalPrice"]?.fieldType = .Item
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(valueObject, forKey: .valueObject)
    }
    
}
