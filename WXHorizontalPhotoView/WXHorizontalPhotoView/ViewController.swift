//
//  ViewController.swift
//  WXHorizontalPhotoView
//
//  Created by Leagon on 16/9/26.
//  Copyright © 2016年 Leagon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WXHorizontalPhotoViewDataSource, WXHorizontalPhotoViewDelegate {
    
    var horizontalPhoto: WXHorizontalPhotoView!
    
    let photos = ["first.jpg", "second.jpg", "third.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        horizontalPhoto = WXHorizontalPhotoView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200), dataSource:self, delegate:self)
        self.view.addSubview(horizontalPhoto)
    }
    
    
    //MARK: - horizontal photo view data source and delegate
    func numberOfPhotos() -> Int {
        return 3
    }
    
    func horizontalPhotoViewEachPhotoAtIndex(_ index: Int) -> UIImage? {
        return UIImage(named: photos[index])
    }
    
    func horizontalPhotoViewShouldAutoScroll() -> Bool {
        return true
    }
    
    func horizontalPhotoViewAutoScrollPeriodInSeconds() -> TimeInterval {
        return 2.5
    }
    
    func horizontalPhotoViewTappedAtIndex(_ index: Int, imageViews: [UIImageView]) {
        print("index = \(index)")
        horizontalPhoto.pauseAutoScroll(true)
    }
}

