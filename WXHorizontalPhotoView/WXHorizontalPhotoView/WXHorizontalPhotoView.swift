//
//  WXHorizontalPhotoView.swift
//  WXHorizontalPhotoView
//
//  Created by Leagon on 15/9/22.
//  Copyright © 2015年 Leagon. All rights reserved.
//

import UIKit

@objc protocol WXHorizontalPhotoViewDataSource {
    func numberOfPhotos() -> Int
    func horizontalPhotoViewEachPhotoAtIndex(index:Int) -> UIImage?
}

@objc protocol WXHorizontalPhotoViewDelegate {
    @objc optional func horizontalPhotoViewShouldAutoScroll() -> Bool
    @objc optional func horizontalPhotoViewAutoScrollPeriodInSeconds() -> NSTimeInterval
    @objc optional func horizontalPhotoViewNeedBlurEffect() -> Bool
    @objc optional func horizontalPhotoViewTappedAtIndex(index:Int, imageView:UIImageView)
}

private let kHorizontalPhotoViewAutoScrollDefaultPeriodInSeconds: NSTimeInterval = 5
private let kHorozontalPhotoViewInfiniteScrollMinPhotoCount:Int = 3

enum WXHorizontalPhotoScrollOrientation {
    case left
    case right
}

class WXHorizontalPhotoView: UIView, UIScrollViewDelegate {
    
    //MARK: - ui property
    private var scrollView = UIScrollView(frame: CGRect.zero)
    private var photoViews = [PhotoView]()
    private var allPhotoImageViews:[UIImageView] {
        return photoViews.map { $0.imageView }
    }
    private var allPhotoBlurredImageViews:[UIImageView] {
        return photoViews.map { $0.blurredImageView }
    }
    
    private var photoIndexView: WXHorizontalPhotoIndexView?
    
    //MARK: - data property
    private var numberOfPhotos = 0
    weak var dataSource: WXHorizontalPhotoViewDataSource?
    
    // 默认循环时间5秒
    private var autoScrollPeriodInSeconds = kHorizontalPhotoViewAutoScrollDefaultPeriodInSeconds
    private var needBlurEffect = false
    private var blurAlpha:CGFloat = 0
    weak var delegate: WXHorizontalPhotoViewDelegate?
    
    // 无线循环机制开关 - 至少需要3张以上的图片
    private var infiniteScrollEnable:Bool {
        get {
            return numberOfPhotos >= kHorozontalPhotoViewInfiniteScrollMinPhotoCount
        }
    }
    private var leftMostImageViewPageIndex = 0
    
    //MARK: - initialize
    init(frame: CGRect, dataSource: WXHorizontalPhotoViewDataSource?, delegate: WXHorizontalPhotoViewDelegate?) {
        
        super.init(frame: frame)
        
        self.dataSource = dataSource
        self.delegate = delegate
        
        func initializeSetup() {
            self.numberOfPhotos = dataSource?.numberOfPhotos() ?? 0
            
            if let needBlurEffect = delegate?.horizontalPhotoViewNeedBlurEffect?() {
                self.needBlurEffect = needBlurEffect
            }
            
            if let autoScrollEnable = delegate?.horizontalPhotoViewShouldAutoScroll?() {
                
                guard autoScrollEnable else {
                    return
                }
                
                if let autoScrollPeriodInSeconds = delegate?.horizontalPhotoViewAutoScrollPeriodInSeconds?() {
                    self.autoScrollPeriodInSeconds = autoScrollPeriodInSeconds
                }
                
                setupAutoScrollTimer()
            }
        }
        
        initializeSetup()
        setupScrollView()
        scrollViewDidScrollToIndex(0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.height = self.bounds.size.height
        scrollView.contentSize = CGSize( width: CGFloat( Int(self.bounds.size.width) * numberOfPhotos ) , height: self.bounds.size.height)
        
        for photoView in photoViews {
            photoView.height = scrollView.height
        }
        photoIndexView?.y = self.bounds.size.height - 30
    }
    
    private func setupScrollView() {
        scrollView.frame = self.bounds
        scrollView.contentSize = CGSize( width: CGFloat(Int(self.bounds.size.width) * numberOfPhotos), height: self.bounds.size.height)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        setupPhotoViews()
        photoIndexView = WXHorizontalPhotoIndexView(frame: CGRect(x: 0, y: self.bounds.size.height - 30, width: self.bounds.size.width, height: 30), maxIndex: numberOfPhotos, currentIndex: 0, selectedColor: UIColor(white: 0, alpha: 0.5), normalColor: UIColor(white: 1, alpha: 0.5))
        self.addSubview(photoIndexView!)
    }
    
    private func setupPhotoViews() {
        for i in 0..<numberOfPhotos {
            let photoView = PhotoView(frame: CGRect( x: CGFloat(Int(self.bounds.size.width) * i), y: 0, width: self.bounds.size.width, height: self.bounds.size.height), tag: i, needBlur: true) as PhotoView
            scrollView.addSubview(photoView)
            photoViews.append(photoView)
            photoView.imageView.userInteractionEnabled = true
            photoView.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WXHorizontalPhotoView.tapImageView(_:))))
        }
    }
    
    //MARK: - public func
    private var autoScrollPause = false
    
    func pauseAutoScroll(pause:Bool) {
        autoScrollPause = pause
    }
    
    func activeBlurEffectWithAlpha(alpha:CGFloat) {
        if needBlurEffect {
            blurAlpha = alpha
            
            for imageView in self.allPhotoBlurredImageViews {
                imageView.alpha = alpha
            }
        }
    }
    
    func scrollToPhotoAtPageIndex(index:Int) {
        if index > numberOfPhotos - 1 {
            return
        }
        
        let scrollIndex = scrollIndexFromPageIndex(index)
        scrollView.setContentOffset(CGPointMake(CGFloat( Int(self.bounds.size.width) * scrollIndex ) , 0), animated: true)
    }
    
    //MARK: - auto scroll
    
    private var autoScrollTimer: NSTimer!
    
    private func shouldEnableAutoScroll() -> Bool {
        return infiniteScrollEnable && autoScrollPeriodInSeconds != 0
    }
    
    private func setupAutoScrollTimer() {
        guard shouldEnableAutoScroll() else {
            return
        }
        startAutoScrollTimer()
    }
    
    private func startAutoScrollTimer() {
        if autoScrollTimer != nil && autoScrollTimer.valid {
            return
        }

        NSTimer.scheduledTimerWithTimeInterval(autoScrollPeriodInSeconds, target: self, selector: #selector(WXHorizontalPhotoView.autoScrollPhoto), userInfo: nil, repeats: true)
    }
    
    private func stopAutoScrollTimer() {
        if autoScrollTimer.valid {
            autoScrollTimer.invalidate()
        }
    }
    
    //MARK: - action
    
    func autoScrollPhoto() {
        if autoScrollPause {
            return
        }
        
        //如果scrollView当前正在被用户操作，或者处于减速状态，忽略此次autoScroll
        if scrollView.dragging || scrollView.tracking || scrollView.decelerating {
            return
        }
        
        var index = Int(scrollView.contentOffset.x / self.bounds.size.width)
        if index < numberOfPhotos - 1 {
            index += 1
        }
        
        scrollView.setContentOffset(CGPoint( x: CGFloat( Int(self.bounds.size.width) * index ) , y: 0), animated: true)
    }
    
    func tapImageView(gesture:UITapGestureRecognizer) {
        delegate?.horizontalPhotoViewTappedAtIndex?((gesture.view?.tag)!, imageView: gesture.view as! UIImageView)
    }
    
    //MARK: - scroll view delegate
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        
        let index = Int( scrollView.contentOffset.x / self.bounds.size.width )
        scrollViewDidScrollToIndex(index)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = Int( scrollView.contentOffset.x / self.bounds.size.width )
        scrollViewDidScrollToIndex(index)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let index = Int( scrollView.contentOffset.x / self.bounds.size.width )
        scrollViewDidScrollToIndex(index)
    }
    
    // MARK: - show image
    
    private func scrollViewDidScrollToIndex(index:Int) {
        
        var internalIndex = index
        
        if infiniteScrollEnable {
            if internalIndex == 0 {
                relayoutImageViewsForInfiniteScrollToOrientation(.left)
                internalIndex += 1
            } else if index == numberOfPhotos - 1 {
                relayoutImageViewsForInfiniteScrollToOrientation(.right)
                internalIndex -= 1
            }
        }
        
        showImageAtPageIndex(pageIndexFromScrollIndex(internalIndex))
        
        if numberOfPhotos > 1 {
            if internalIndex + 1 < numberOfPhotos {
                showImageAtPageIndex(pageIndexFromScrollIndex(internalIndex+1))
            }
            
            if internalIndex > 0 {
                showImageAtPageIndex(pageIndexFromScrollIndex(internalIndex-1))
            }
        }
        
        photoIndexView?.updateToNewPageIndex(pageIndexFromScrollIndex(internalIndex))
    }
    
    private func relayoutImageViewsForInfiniteScrollToOrientation(orientation: WXHorizontalPhotoScrollOrientation) {
        var originContentOffset = scrollView.contentOffset
        
        switch orientation {
        case .left:
            leftMostImageViewPageIndex = leftMostImageViewPageIndex == 0 ? numberOfPhotos - 1 : leftMostImageViewPageIndex - 1
            for photoView in photoViews {
                if photoView.tag == leftMostImageViewPageIndex {
                    photoView.x = 0
                } else {
                    photoView.x += self.bounds.size.width
                }
            }
            
            originContentOffset.x += self.bounds.width
            scrollView.setContentOffset(originContentOffset, animated: false)
            
        case .right:
            for photoView in photoViews {
                if photoView.tag == leftMostImageViewPageIndex {
                    photoView.x = self.bounds.size.width * CGFloat(numberOfPhotos - 1)
                } else {
                    photoView.x -= self.bounds.size.width
                }
            }
            
            originContentOffset.x -= self.bounds.size.width
            scrollView.setContentOffset(originContentOffset, animated: false)
            
            leftMostImageViewPageIndex = leftMostImageViewPageIndex == numberOfPhotos - 1 ? 0 : leftMostImageViewPageIndex + 1
        }
    }
    
    private func showImageAtPageIndex(index:Int) {
        guard photoViews[index].imageViewFirstShow else {
            return
        }
        
        photoViews[index].imageViewFirstShow = false
        
        let photoResource = dataSource?.horizontalPhotoViewEachPhotoAtIndex(index)
        let imageView = photoViews[index].imageView
        
        // 网络加载图片时需要加载动画
        let spinView = photoViews[index].loadingImageIndicatorView
        
        imageView.image = photoResource
    }
    
    private func pageIndexFromScrollIndex(scrollIndex:Int) -> Int {
        return (leftMostImageViewPageIndex + scrollIndex) % numberOfPhotos
    }
    
    private func scrollIndexFromPageIndex(pageIndex:Int) -> Int {
        return (pageIndex + numberOfPhotos - leftMostImageViewPageIndex) % numberOfPhotos
    }
}
