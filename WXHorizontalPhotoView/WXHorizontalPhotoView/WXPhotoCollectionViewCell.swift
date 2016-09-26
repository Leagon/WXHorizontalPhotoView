//
//  WXPhotoCollectionViewCell.swift
//  WXHorizontalPhotoView
//
//  Created by Leagon on 16/9/26.
//  Copyright © 2016年 Leagon. All rights reserved.
//

import UIKit

@objc protocol WXPhotoCollectionViewCellDelegate {
    func tapPhotoCollectionViewCell(cell: WXPhotoCollectionViewCell)
}

class WXPhotoCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {

    let imageView = UIImageView()
    let scrollView = UIScrollView()
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    weak var delegate: WXPhotoCollectionViewCellDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.frame = bounds
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        contentView.addSubview(scrollView)
        
        imageView.frame = scrollView.bounds
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = UIColor.clearColor()
        scrollView.addSubview(imageView)
        
        activityIndicatorView.center = CGPointMake(frame.width / 2, frame.height / 2)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        contentView.addSubview(activityIndicatorView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(WXPhotoCollectionViewCell.tapImageView))
        imageView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapImageView() {
        delegate?.tapPhotoCollectionViewCell(self)
    }
}

extension UICollectionViewCell {
    class func identifier() -> String {
        return UICollectionViewCell.className(self)
    }
    
    class func className(obj: AnyClass) -> String {
        return NSStringFromClass(obj).componentsSeparatedByString(".").last!
    }
}
