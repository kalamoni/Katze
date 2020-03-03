//
//  CatsCollectionViewCell.swift
//  Katze
//
//  Created by Mohamed Salama on 3/2/20.
//  Copyright © 2020 Mohamed Salama. All rights reserved.
//

import UIKit

protocol CatsCollectionViewCellDelegate {
    func didTap(onRow row: Int)
}

class CatsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var addToFavButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var delegate: CatsCollectionViewCellDelegate?
    var row = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 10
        addToFavButton.setBackgroundImage(#imageLiteral(resourceName: "heart_unselected"), for: .normal)
        addToFavButton.setBackgroundImage(#imageLiteral(resourceName: "heart_selected"), for: .selected)
        activityIndicator.isHidden = false
    }
    
    func resetCell() {
        imageView.image = nil
        addToFavButton.isSelected = false
        activityIndicator.isHidden = false
    }
    
    func isFav(_ selected: Bool) {
        addToFavButton.isSelected = selected
    }
    
    func setImage(with image: UIImage?) {
        activityIndicator.isHidden = true
        imageView.image = image
    }
    
    @IBAction func didTapAddToFav(_ sender: UIButton) {
        
        if addToFavButton.isSelected {
            UIView.animate(withDuration: 1, animations: {
                
                let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
                pulseAnimation.duration = 0.2
                pulseAnimation.fromValue = 1
                pulseAnimation.toValue = 0.2
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = 1
                self.addToFavButton.layer.add(pulseAnimation, forKey: "animateBrokenHeart")
                
                
            }) { (success: Bool) in
                
                
            }
        } else {
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 0.2
            pulseAnimation.fromValue = 1
            pulseAnimation.toValue = 1.3
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = 2
            addToFavButton.layer.add(pulseAnimation, forKey: "animateHeart")
        }
        
        addToFavButton.isSelected = !addToFavButton.isSelected
        delegate?.didTap(onRow: row)
    }
    
}
