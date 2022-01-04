//
//  HTTPManagerProtocol.swift
//  sYg
//
//  Created by Jack Wang on 1/3/22.
//

import Foundation
import UIKit


/*
 * Protocol for doing any type of HTTP Request
 *  To do HTTP Request:
 *     1. Session (shared)
 *     2. URL -> URLRequest
 *     3. Completion Action (Block)
 *
 */
enum HTTPError: Error {
    case invalidURL
    case noInternet
    case invalidResponse(Data?, URLResponse?)
}

protocol HTTPManagerProtocol {
    /*
     * Type will be generic conforming to URLSessionProtocol
     */
    associatedtype aType
    var session: aType { get }
    
    init(session: aType)
    
    /*
     * Make Request
     */
    func makeRequest(request: URLRequest, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void)
}
