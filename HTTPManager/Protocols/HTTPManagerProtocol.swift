//
//  HTTPManagerProtocol.swift
//  sYg
//
//  Taken from: https://github.com/stevencurtis/BasicHTTPManager
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

protocol HTTPManagerProtocol {
    /*
     * Type will be generic conforming to URLSessionProtocol
     */
    associatedtype aType
    var session: aType { get }
    
    init(session: aType)
    
    
    func makeRequest(with url: URL, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void)
    
    /*
     * Make Request
     *  - Result contains actual returned data
     *  - URLResponse used by AzureHTTPManager for example to check status of request.
     */
    func makeRequest(request: URLRequest, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void)
    
    
}
