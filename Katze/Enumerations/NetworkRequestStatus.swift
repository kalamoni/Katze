//
//  NetworkRequestStatus.swift
//  Katze
//
//  Created by Mohamed Salama on 3/2/20.
//  Copyright © 2020 Mohamed Salama. All rights reserved.
//

import Foundation

enum NetworkRequestStatus: Error {
        
    /// Request failed.
    case error
    
    /// Request timed out.
    case timeout
    
    /// Parsing response failed.
    case parsingError
    
    /// Decoding repsonse failed.
    case decodingError
    
    /// Encoding repsonse failed.
    case encodingError
    
    /// Percent encoding URL failed.
    case invalidPercentEncoding
    
    /// One or both of credential parameters are not correct.
    case invalidCredentials
}
