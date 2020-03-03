//
//  FavoritesViewController.swift
//  Katze
//
//  Created by Mohamed Salama on 3/2/20.
//  Copyright © 2020 Mohamed Salama. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var favPlaceHolder: UILabel!
    @IBOutlet weak var catsCollectionView: UICollectionView!
    
    private let progressHUD = ProgressHUD(text: "Loading")
    private var cats: [Cat] = []
    
    private struct Constants {
        static let cellIdentifier = String(describing: CatsCollectionViewCell.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    private func setupScene() {
        catsCollectionView.delegate = self
        catsCollectionView.dataSource = self
        
        let nib = UINib(nibName: Constants.cellIdentifier, bundle: Bundle(for: CatsCollectionViewCell.self))
        catsCollectionView.register(nib, forCellWithReuseIdentifier: Constants.cellIdentifier)
    }
    
    private func reloadData() {
        favPlaceHolder.isHidden = !CatsController.shared.favCats.isEmpty
        catsCollectionView.reloadData()
    }
    
}

extension FavoritesViewController: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CatsController.shared.favCats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath)
        
        guard let catsCell = cell as? CatsCollectionViewCell, indexPath.row < CatsController.shared.favCats.count else { return cell }
        let cat = CatsController.shared.favCats[indexPath.row]
        catsCell.tag = cat.id.hashValue
        catsCell.resetCell()
        catsCell.delegate = self
        catsCell.isFav(CatsController.shared.isFav(id: cat.id))
        catsCell.row = indexPath.row
        CatsController.shared.fetchImage(withURL: cat.imageURL) { (image) in
            DispatchQueue.main.async {
                if catsCell.tag == cat.id.hashValue {
                    catsCell.setImage(with: image)
                }
            }
        }
        
        return catsCell
    }
    
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    /*
     // MARK: - UICollectionViewDelegateFlowLayout
     
     */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.bounds.size.width - 16)
        let cellHeight = CGFloat(250)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}

extension FavoritesViewController: CatsCollectionViewCellDelegate {
    func didTap(onRow row: Int) {
        guard row < CatsController.shared.favCats.count else { return }
        let cat = CatsController.shared.favCats[row]
        CatsController.shared.removeFromFav(cat)
        reloadData()
    }
}
