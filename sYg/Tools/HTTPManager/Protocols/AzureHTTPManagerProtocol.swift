//
//  AzureHTTPManagerProtocol.swift
//  sYg
//
//  Created by Jack Wang on 1/3/22.
//

import Foundation
import UIKit

protocol AzureHTTPManagerProtocol {
    
    /*
     * GET Request
     */
    func get(url: URL, key: String, completionBlock: @escaping (Result<Data, Error>) -> Void)
    
    /*
     * POST Request
     */
    func post(url: URL, image: UIImage, key: String, completionBlock: @escaping (Result<Data, Error>) -> Void)
    
}
