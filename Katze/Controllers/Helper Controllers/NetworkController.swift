//
//  NetworkController.swift
//  Katze
//
//  Created by Mohamed Salama on 3/2/20.
//  Copyright © 2020 Mohamed Salama. All rights reserved.
//

import UIKit

class NetworkController {
    
    private init() {
        configureCache()
    }
    
    /// The shared instance of the Netwrok controller singleton.
    static let shared = NetworkController()
    
    /// The shared local cache of the Netwrok controller singleton.
    private let imageCache = NSCache<NSString, UIImage>()
    
    private struct API {
        static let apiKey = "f2211390-de6a-4292-88c1-eca84177c6a0"
        static let baseURL = "api.thecatapi.com"
        static let version = "/v1"
        static let search = "/images/search"
    }
    
    private struct Constants {
        static let userDefaultKey = "userDefaultKeyForFavorites"
    }
    
    /*
     // MARK: - Class Methods
     */
    
    /**
     Configures and sets the global in-memory and disk cache sizes for the URLRequest used in every URLSession request.
     
     - author: Mohamed Salama
     */
    private func configureCache() {
        let temporaryDirectory = NSTemporaryDirectory()
        let urlCache = URLCache(memoryCapacity: 25_000_000,
                                diskCapacity: 50_000_000, diskPath: temporaryDirectory)
        URLCache.shared = urlCache
        
        imageCache.countLimit = 50_000_000
        imageCache.totalCostLimit = 50_000_000
    }
    
    /**
     Purges and emptys the images cache.
     
     - author: Mohamed Salama
     */
    func purgeCache() {
        imageCache.removeAllObjects()
    }
    
    /*
     // MARK: - Cats
     */
    /**
     Retrieves an array of cats objects over the netwrok, and calls a handler upon completion.
     
     - parameter page: Page number offset to be fetched.
     - parameter limit: Number of items to be fetched.
     - parameter completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
     
     - author: Mohamed Salama
     */
    func fetchCats(forPage page: Int, withLimit limit: Int, completionHandler: @escaping (Result<[Cat], NetworkRequestStatus>) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = API.baseURL
        urlComponents.path = API.version.appending(API.search)
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "order", value: "Asc")
        ]
        
        guard let url = urlComponents.url?.absoluteURL else {
            completionHandler(.failure(.encodingError))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(API.apiKey, forHTTPHeaderField: "x-api-key")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                if error.localizedDescription.contains("timed out") {
                    completionHandler(.failure(.timeout))
                } else {
                    completionHandler(.failure(.error))
                }
            } else if let responseData = data {
                
                do {
                    let decoder = JSONDecoder()
                    if let cats = try? decoder.decode([Cat].self, from: responseData) {
                        completionHandler(.success(cats))
                    } else if let _ = try? decoder.decode(ErrorResponse.self, from: responseData) {
                        completionHandler(.failure(.decodingError))
                    }
                }
                
            } else {
                completionHandler(.failure(.parsingError))
            }
        }.resume()
        
    }
    
    /**
    Persists the favorite cats list permanently to the `UserDefaults`.
    
    - parameter cat: The `Cat` object to be added.
    
    - author: Mohamed Salama
    */
    func saveFavCatsList(_ catList: [Cat]) {
        if let encodedData = try? JSONEncoder().encode(catList) {
            UserDefaults.standard.set(encodedData, forKey: Constants.userDefaultKey)
        }
    }
    
    /**
    Loads the favorite cats list from the `UserDefaults`.
    
    - returns: The favorite `Cat` list.
    
    - author: Mohamed Salama
    */
    func loadFavCatsList() -> [Cat] {
        if let userData = UserDefaults.standard.data(forKey: Constants.userDefaultKey), let cats = try? JSONDecoder().decode([Cat].self, from: userData) {
            return cats
        } else {
            return []
        }
    }
    
    /*
     // MARK: - Fetching Images
     */
    /**
     Retrieves an image URL over the netwrok, and calls a handler upon completion.
     
     - parameter imgURL: A string represents the full image URL.
     - parameter completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
     
     - remark: Checks if the image is available in the cache before fetching it over the network. If not present, the image is fetched and cached for future usage.
     - author: Mohamed Salama
     */
    func fetchImage(withURL imgURL: String, completionHandler: @escaping (Result<UIImage?, NetworkRequestStatus>) -> Void) {
        
        guard let imagURLPercentEncoded = imgURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            completionHandler(.failure(.invalidPercentEncoding))
            return
        }
        
        if let cachedImage = self.imageCache.object(forKey: imagURLPercentEncoded as NSString) {
            completionHandler(.success(cachedImage))
            
        } else {
            let urlAPI = URL(string: imagURLPercentEncoded)
            guard let url = urlAPI else {
                completionHandler(.failure(.error))
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 60
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if error.localizedDescription.contains("timed out") {
                        completionHandler(.failure(.timeout))
                    } else {
                        completionHandler(.failure(.error))
                    }
                } else if let imageData = data, let image = UIImage(data: imageData) {
                    
                    self.imageCache.setObject(image, forKey: imgURL as NSString, cost: imageData.count)
                    completionHandler(.success(image))
                } else {
                    completionHandler(.failure(.error))
                }
            }.resume()
        }
    }
}
