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
        horizontalPhoto = WXHorizontalPhotoView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 200), dataSource:self, delegate:self)
        self.view.addSubview(horizontalPhoto)
    }
    
    
    //MARK: - horizontal photo view data source and delegate
    func numberOfPhotos() -> Int {
        return 3
    }
    
    func horizontalPhotoViewEachPhotoAtIndex(index: Int) -> UIImage? {
        return UIImage(named: photos[index])
    }
    
    func horizontalPhotoViewShouldAutoScroll() -> Bool {
        return true
    }
    
    func horizontalPhotoViewAutoScrollPeriodInSeconds() -> NSTimeInterval {
        return 2.5
    }
    
    func horizontalPhotoViewTappedAtIndex(index: Int, imageViews: [UIImageView]) {
        print("index = \(index)")
        horizontalPhoto.pauseAutoScroll(true)
    }
}

