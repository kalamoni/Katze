//
//  CatsController.swift
//  Katze
//
//  Created by Mohamed Salama on 3/2/20.
//  Copyright © 2020 Mohamed Salama. All rights reserved.
//

import UIKit

class CatsController {
    
    private init() {
        loadFavorites()
    }
    
    /// The shared instance of the cats controller singleton.
    static var shared = CatsController()
    
    /// The number of pages fetched so far.
    private var page = 0
    
    /// Number of items to fetch per network call
    private let limit = 10
    
    /// Number of items to fetch per network call
    var favCats: [Cat] = []
    
    /**
    Loads the favorite cats list from the local cache.
     
    - author: Mohamed Salama
    */
    private func loadFavorites() {
        favCats = NetworkController.shared.loadFavCatsList()
    }
    
    /**
    Adds a cat object to the favorite list.
    
    - parameter cat: The `Cat` object to be added.
    
    - author: Mohamed Salama
    */
    func addToFav(_ cat: Cat) {
        favCats.append(cat)
        NetworkController.shared.saveFavCatsList(favCats)
    }
    
    /**
    Removes a cat object from the favorite list.
    
    - parameter cat: The `Cat` object to be remove.
    
    - author: Mohamed Salama
    */
    func removeFromFav(_ cat: Cat) {
        favCats.removeAll { $0 == cat }
        NetworkController.shared.saveFavCatsList(favCats)
    }
    
    /**
     Checks whether the `ID` of this cat object is added to the favorite list or not.
     
     - parameter id: The `ID` of the corresponding cat object.
     - Returns: A bool represents the availability of the the cat object in the favorite list.
     
     - author: Mohamed Salama
     */
    func isFav(id: String) -> Bool {
        return !favCats.filter { $0.id.hashValue == id.hashValue }.isEmpty
    }
    
    /**
     Retrieves an array of cats objects using the netwrok controller, and calls a handler upon completion.
     
     - parameter completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
     
     - author: Mohamed Salama
     */
    func fetchCats(completionHandler: @escaping (_ cats: [Cat]) -> Void) {
        
        NetworkController.shared.fetchCats(forPage: page, withLimit: limit) { result in
            
            switch result {
            case .success(let cats):
                self.page += 1
                completionHandler(cats)
            case .failure( _):
                completionHandler([])
            }
        }
    }
    
    /**
     Retrieves an image URL over the netwrok controller, and calls a handler upon completion.
     
     - parameter imgURL: A string represents the full image URL.
     - parameter completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
     
     - remark: Checks if the image is available in the cache before fetching it over the network. If not present, the image is fetched and cached for future usage.
     - author: Mohamed Salama
     */
    func fetchImage(withURL imgURL: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        NetworkController.shared.fetchImage(withURL: imgURL) { (result) in
            switch result {
            case .success(let image):
                completionHandler(image)
            case .failure( _):
                completionHandler(nil)
            }
        }
    }
}
