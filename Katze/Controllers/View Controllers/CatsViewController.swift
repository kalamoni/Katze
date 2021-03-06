//
//  CatsViewController.swift
//  Katze
//
//  Created by Mohamed Salama on 3/2/20.
//  Copyright © 2020 Mohamed Salama. All rights reserved.
//

import UIKit

class CatsViewController: UIViewController {
    
    @IBOutlet weak var catsCollectionView: UICollectionView!
    
    private let progressHUD = ProgressHUD(text: "Loading")
    private var cats: [Cat] = []
    
    struct Constants {
        static let cellIdentifier = String(describing: CatsCollectionViewCell.self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        catsCollectionView.reloadData()
    }
    
    private func setupScene() {
        catsCollectionView.delegate = self
        catsCollectionView.dataSource = self
        
        let nib = UINib(nibName: Constants.cellIdentifier, bundle: Bundle(for: CatsCollectionViewCell.self))
        catsCollectionView.register(nib, forCellWithReuseIdentifier: Constants.cellIdentifier)
    }
    
    /*
     // MARK: - Class Methods
     */
    
    /**
     Fetches cats data over the network using Cats Controller.
     
     - author: Mohamed Salama
     */
    func fetchData() {
        view.addSubview(progressHUD)
        CatsController.shared.fetchCats { cats in
            DispatchQueue.main.async {
                self.progressHUD.removeFromSuperview()
                self.cats = self.cats + cats
                self.catsCollectionView.reloadData()
            }
        }
    }
    
}

extension CatsViewController: UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row == cats.count - 1 else {
            return
        }
        fetchData()
    }
    
}

extension CatsViewController: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath)
        
        guard let catsCell = cell as? CatsCollectionViewCell, indexPath.row < cats.count else { return cell }
        let cat = cats[indexPath.row]
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

extension CatsViewController: UICollectionViewDelegateFlowLayout {
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

extension CatsViewController: CatsCollectionViewCellDelegate {
    func didTap(onRow row: Int) {
        guard row < cats.count else { return }
        let cat = cats[row]
        if CatsController.shared.isFav(id: cat.id) {
            CatsController.shared.removeFromFav(cat)
        } else {
            CatsController.shared.addToFav(cat)
        }
    }
}
