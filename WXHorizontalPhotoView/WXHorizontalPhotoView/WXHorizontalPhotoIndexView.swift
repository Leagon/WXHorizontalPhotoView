//
//  WXHorizontalPhotoIndexView.swift
//  WXHorizontalPhotoIndexView
//
//  Created by Leagon on 15/9/22.
//  Copyright © 2015年 Leagon. All rights reserved.
//

import UIKit

private let kIndexRoundRadius:CGFloat = 3
private let kIndexRoundGap:CGFloat = 10
private let kYOffset:CGFloat = 10

class WXHorizontalPhotoIndexView: UIView {
    fileprivate var indexRoundShapes = [CAShapeLayer]()
    fileprivate var currentIndex:Int
    fileprivate var maxIndex:Int
    fileprivate var selectedColor:UIColor
    fileprivate var normalColor:UIColor
    fileprivate var strokeColor:UIColor?
    
    init(frame:CGRect, maxIndex:Int, currentIndex:Int, selectedColor:UIColor, normalColor:UIColor, strokeColor:UIColor?) {
        
        self.currentIndex = currentIndex
        self.maxIndex = maxIndex
        self.selectedColor = selectedColor
        self.normalColor = normalColor
        self.strokeColor = strokeColor
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        let yPosition = self.frame.size.height - kIndexRoundRadius - kYOffset
        for i in 0..<maxIndex {
            let round = CAShapeLayer()
            round.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: kIndexRoundRadius * 2, height: kIndexRoundRadius * 2)).cgPath
            
            let xPosition = frame.size.width/2 - ( CGFloat(maxIndex) * kIndexRoundGap + CGFloat(maxIndex + 1)*kIndexRoundRadius/2 ) + CGFloat(i) * (kIndexRoundGap + kIndexRoundRadius)
            
            round.frame = CGRect(x: xPosition, y: yPosition, width: kIndexRoundRadius * 2, height: kIndexRoundRadius * 2)
            
            if currentIndex == i {
                round.fillColor = selectedColor.cgColor
                round.strokeColor = selectedColor.cgColor
            } else {
                round.fillColor = normalColor.cgColor
                round.strokeColor = strokeColor?.cgColor ?? normalColor.cgColor
            }
            
            self.layer.addSublayer(round)
            indexRoundShapes.append(round)
        }
    }

    convenience init(frame:CGRect, maxIndex:Int, currentIndex:Int, selectedColor:UIColor, normalColor:UIColor) {
        self.init(frame:frame, maxIndex:maxIndex, currentIndex:currentIndex, selectedColor:selectedColor, normalColor:normalColor, strokeColor:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateToNewPageIndex(_ newIndex:Int) {
        if newIndex == self.currentIndex {
            return
        }
        
        indexRoundShapes[currentIndex].fillColor = normalColor.cgColor
        indexRoundShapes[currentIndex].strokeColor = strokeColor?.cgColor ?? normalColor.cgColor
        
        indexRoundShapes[newIndex].fillColor = selectedColor.cgColor
        indexRoundShapes[newIndex].strokeColor = selectedColor.cgColor
        
        currentIndex = newIndex
    }
}


private let kPhotoViewSpinViewSize:CGFloat = 10

class PhotoView: UIView {
    
    var imageView = UIImageView(frame: CGRect.zero)
    var blurredImageView = UIImageView(frame: CGRect.zero)
    var loadingImageIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var imageViewFirstShow = true
    
    init(frame:CGRect, tag:Int, needBlur:Bool) {
        super.init(frame: frame)
        
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tag = tag
        
        blurredImageView.frame = self.bounds
        blurredImageView.contentMode = .scaleAspectFill
        blurredImageView.clipsToBounds = true
        
        loadingImageIndicatorView.frame = CGRect( x: (self.bounds.size.width - kPhotoViewSpinViewSize)/2, y: (self.bounds.size.height - kPhotoViewSpinViewSize)/2, width: kPhotoViewSpinViewSize, height: kPhotoViewSpinViewSize)
        
        self.addSubview(imageView)
        self.addSubview(loadingImageIndicatorView)
        if needBlur {
            self.addSubview(blurredImageView)
        }
        
        self.tag = tag
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.height = self.bounds.size.height
        self.blurredImageView.height = self.bounds.size.height
        self.loadingImageIndicatorView.center = self.center
    }
}

extension UIView {
    var height:CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var newFrame = self.frame
            newFrame.size.height = newValue
            self.frame = newFrame
        }
    }
    
    var x:CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var newFrame = self.frame
            newFrame.origin.x = newValue
            self.frame = newFrame
        }
    }
    
    var y:CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var newFrame = self.frame
            newFrame.origin.y = newValue
            self.frame = newFrame
        }
    }
}
