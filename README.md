# WXHorizontalPhotoView
	let photos = ["first.jpg", "second.jpg", "third.jpg"]
	
	horizontalPhoto = HorizontalPhotoView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 200), dataSource:self, delegate:self)
	
	// dataSource
    func numberOfPhotos() -> Int {
        return 3
    }
    
    func HorizontalPhotoViewEachPhotoAtIndex(index: Int) -> UIImage? {
        return UIImage(named: photos[index])
    }

	// delegate
	
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
    