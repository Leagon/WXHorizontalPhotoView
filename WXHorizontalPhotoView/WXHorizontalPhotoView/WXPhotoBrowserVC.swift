//
//  WXPhotoBrowserVC.swift
//  WXHorizontalPhotoView
//
//  Created by Leagon on 16/9/26.
//  Copyright © 2016年 Leagon. All rights reserved.
//

import UIKit

class WXPhotoBrowserVC: UIViewController {

    private var photoCollectionView: UICollectionView!
    private var flowLayout = UICollectionViewFlowLayout()
    
    private var toolBar: UIToolbar!
    private var countNumber = UILabel()
    
    private var photos: [AnyObject]!
    
    private var selectedCell: WXPhotoCollectionViewCell!
    
    var animationView: UIView!
    var currentIndex = 0
    var dismissComplete: (() -> Void)!
    
    // MARK: - initialized
    
    init(images: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        self.photos = images
    }
    
    init(urls: [NSURL]) {
        super.init(nibName: nil, bundle: nil)
        self.photos = urls
    }
    
    init(photos: [AnyObject]) {
        super.init(nibName: nil, bundle: nil)
        self.photos = photos
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.blackColor()
        self.transitioningDelegate = self
        
        initializedSetup()
        
    }
    
    func initializedSetup() {
     
        func setupCollectionView() {
            flowLayout.scrollDirection = .Horizontal
            flowLayout.itemSize = view.bounds.size
            flowLayout.minimumLineSpacing = 0
            
            photoCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
            photoCollectionView.backgroundColor = UIColor.clearColor()
            photoCollectionView.delegate = self
            photoCollectionView.dataSource = self
            photoCollectionView.pagingEnabled = true
            photoCollectionView.registerClass(WXPhotoCollectionViewCell.self, forCellWithReuseIdentifier: WXPhotoCollectionViewCell.identifier())
            view.addSubview(photoCollectionView)
        }
        
        func setupCountNumber() {
            countNumber.textColor = UIColor.whiteColor()
            countNumber.frame = CGRectMake(0, 0, 50, 20)
            countNumber.textAlignment = .Center
            updateCountNumber()
        }
        
        func setupToolbar() {
            toolBar = UIToolbar(frame: CGRectMake(0, view.height - 44, view.width, 44))
            toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
            toolBar.backgroundColor = UIColor.colorHex(0x121212)
            view.addSubview(toolBar)
        }
        
        setupCollectionView()
        setupCountNumber()
        setupToolbar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        photoCollectionView.hidden = true
        photoCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: false)
        selectedCell = photoCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as? WXPhotoCollectionViewCell
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        photoCollectionView.hidden = false
    }

    
    // MARK: - private method
    private func acitivityIndicatorAnimation(cell: WXPhotoCollectionViewCell, flag: Bool) {
        dispatch_async(dispatch_get_main_queue()) { 
            if flag {
                cell.activityIndicatorView.startAnimating()
            } else {
                cell.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    private func updateCountNumber() {
        countNumber.text = "\(currentIndex + 1)/\(photos.count)"
    }
    
    // MARK: - public method
    func showPhotoBrowser(inViewController vc: UIViewController) {
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .Custom
        vc.presentViewController(self, animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension WXPhotoBrowserVC: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return WXPresentedAnimation(fromVcOriginalView: animationView)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return WXDismissedAnimation(fromView: selectedCell.imageView, toView: animationView)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension WXPhotoBrowserVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(WXPhotoCollectionViewCell.identifier(), forIndexPath: indexPath) as! WXPhotoCollectionViewCell
        cell.delegate = self
        self.acitivityIndicatorAnimation(cell, flag: true)
        
        switch photos[indexPath.row] {
        case let url as NSURL:
            // need sdwebImage or other 3rd library
            break
        case let image as UIImage:
            self.acitivityIndicatorAnimation(cell, flag: false)
            cell.imageView.image = image
        default:
            break
        }
        
        cell.backgroundColor = UIColor.clearColor()
        return cell
        
    }
}

// MARK: - WXPhotoCollectionViewCellDelegate
extension WXPhotoBrowserVC: WXPhotoCollectionViewCellDelegate {
    func tapPhotoCollectionViewCell(cell: WXPhotoCollectionViewCell) {
        selectedCell = cell
        dismissViewControllerAnimated(true) { 
            if let dismissBlock = self.dismissComplete {
                dismissBlock()
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / flowLayout.itemSize.width)
        updateCountNumber()
    }
}

// MARK: - UIColor Extension
extension UIColor {
    class func colorHex(rgbHex:Int) -> UIColor {
        return UIColor.colorHexAlpha(rgbHex, alpha: CGFloat(1.0))
    }
    
    class func colorHexAlpha(rgbHex:Int, alpha:CGFloat) -> UIColor {
        let red = CGFloat((rgbHex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((rgbHex & 0xff00) >> 8) / 255.0
        let blue = CGFloat((rgbHex & 0xff) >> 0) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: Present and Dismiss transitioning animation
class WXPresentedAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var fromVcOriginalView: UIView
    
    init(fromVcOriginalView: UIView) {
        self.fromVcOriginalView = fromVcOriginalView
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        container.backgroundColor = UIColor.blackColor()
        
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        fromVC?.view.alpha = 0.0
        
        guard let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? WXPhotoBrowserVC else {
            return
        }
        toVC.view.alpha = 0
        
        let originalView: UIView
        if fromVcOriginalView is UIImageView {
            let copyView = UIImageView(frame: fromVcOriginalView.frame)
            copyView.image = (fromVcOriginalView as! UIImageView).image
            copyView.contentMode = .ScaleAspectFit
            originalView = copyView
        } else {
            if let fromView = fromVcOriginalView.snapshotViewAfterScreenUpdates(true) {
                originalView = fromView
            } else {
                originalView = UIView()
            }
        }
        
        guard let toolBarSnapshot = toVC.toolBar.snapshotViewAfterScreenUpdates(true) else {
            return
        }
        toolBarSnapshot.frame = toVC.toolBar.frame
        
        container.addSubview(originalView)
        container.addSubview(toVC.view)
        container.addSubview(toolBarSnapshot)
        
        let finalFrame = transitionContext.finalFrameForViewController(toVC)
        if let originalViewRect = fromVcOriginalView.superview?.convertRect(fromVcOriginalView.frame, toView: container) {
            originalView.frame = originalViewRect
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseOut, animations: { 
            originalView.frame = finalFrame
            }) { (finished) in
                originalView.removeFromSuperview()
                toolBarSnapshot.removeFromSuperview()
                toVC.view.alpha = 1
                transitionContext.completeTransition(true)
        }
    }
}

class WXDismissedAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var fromVcOriginalView: UIImageView
    var toVcOriginalView: UIView
    
    init(fromView: UIImageView, toView: UIView) {
        self.fromVcOriginalView = fromView
        self.toVcOriginalView = toView
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        
        guard let fromVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            return
        }
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        toVC?.view.alpha = 1.0
        
        let fromVcView = UIImageView(frame: fromVcOriginalView.frame)
        fromVcView.image = fromVcOriginalView.image
        fromVcView.contentMode = .ScaleAspectFit
        
        container.addSubview(fromVc.view)
        container.addSubview(fromVcView)
        
        let toVcOriginalRect = toVcOriginalView.superview!.convertRect(toVcOriginalView.frame, toView: container)
        
        fromVcOriginalView.alpha = 0
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseOut, animations: { 
            fromVcView.frame = toVcOriginalRect
            fromVcView.alpha = 0
            fromVc.view.alpha = 0
            }) { (finished) in
                fromVcView.removeFromSuperview()
                transitionContext.completeTransition(true)
        }
    }
}
