//
//  OverlayView.m
//  AgileCapture
//
//
//  created by Incept Development
//  2011 Incept Development. All rights reserved

#import "OverlayView.h"

@implementation OverlayView

UIView *_buttonPanel;
UIButton *_captureButton;
UIButton *_backButton;

@synthesize overlayGraphic = _overlayGraphic;


- (id)initWithFrame:(CGRect)frame
{
      CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (self == [super initWithFrame:frame])
	{
        
        self.backgroundColor = [UIColor clearColor];
		
		//side = [mySetGet getfrontback:side];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height < 481.0f) {    /*  Resolution : 320x480   */
                /*Do iPhone Classic stuff here.*/
                self.overlayGraphic = [UIImage imageNamed:@"iPhone4.png"];
            } else if(screenSize.height < 569.0f){    /*  Resolution : 320x568   */
                /*Do iPhone 5 stuff here.*/
                self.overlayGraphic = [UIImage imageNamed:@"iPhone5.png"];
            } else if(screenSize.height < 668.0f){     /*  Resolution : 375 × 667   */
                /*Do iPhone 6 stuff here.*/
                self.overlayGraphic = [UIImage imageNamed:@"iPhone6.png"];
            } else if(screenSize.height < 737.0f){     /*  Resolution : 414 × 736   */
                /*Do iPhone 6 PLUS stuff here.*/
                self.overlayGraphic = [UIImage imageNamed:@"iPhone6Plus.png"];
            }

        } else {
            /*Do iPad stuff here.*/
            self.overlayGraphic = [UIImage imageNamed:@"iPad.png"];
        }

		UIImageView *overlayGraphicView = [[UIImageView alloc] initWithImage:self.overlayGraphic];
		//overlayGraphicView.frame = CGRectMake(5, 5, 200, 415);
        
        
        //*************  Increasing the height of overlay image according to the device dimenstion **********
      
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height < 481.0f) {    /*  Resolution : 320x480   */
                /*Do iPhone Classic stuff here.*/
                overlayGraphicView.frame = CGRectMake(0, 0, 320, 436);
            } else if(screenSize.height < 569.0f){    /*  Resolution : 320x568   */
                /*Do iPhone 5 stuff here.*/
                overlayGraphicView.frame = CGRectMake(0, 0, 320, 518);
            } else if(screenSize.height < 668.0f){     /*  Resolution : 375 × 667   */
                /*Do iPhone 6 stuff here.*/
                overlayGraphicView.frame = CGRectMake(0, 0, 375, 617);
            } else if(screenSize.height < 737.0f){     /*  Resolution : 414 × 736   */
                /*Do iPhone 6 PLUS stuff here.*/
                overlayGraphicView.frame = CGRectMake(0, 0, 414, 686);
            }
            
        } else {
            /*Do iPad stuff here.*/
             overlayGraphicView.frame = CGRectMake(0, 0, 768, 1024-55);
        }
        
        // ******* End ********
        
        
        // ******* Button Panel ********
//        _buttonPanel = [[UIView alloc] initWithFrame:CGRectZero];
//        [_buttonPanel setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.75f]];
//        [parentView addSubview:_buttonPanel];
//        
//        _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_captureButton setImage:[UIImage imageNamed:@"cameraoverlay/capture_button.png"] forState:UIControlStateNormal];
//        [_captureButton setImage:[UIImage imageNamed:@"cameraoverlay/capture_button_pressed.png"] forState:UIControlStateSelected];
//        [_captureButton setImage:[UIImage imageNamed:@"cameraoverlay/capture_button_pressed.png"] forState:UIControlStateHighlighted];
//        [_captureButton addTarget:self action:@selector(shootPicture) forControlEvents:UIControlEventTouchUpInside];
//        [parentView addSubview:_captureButton];
//        
//        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_backButton setBackgroundImage:[UIImage imageNamed:@"cameraoverlay/capture_button.png"] forState:UIControlStateNormal];
//        [_backButton setBackgroundImage:[UIImage imageNamed:@"cameraoverlay/capture_button.png"] forState:UIControlStateHighlighted];
//        [_backButton setTitle:@"Cancel" forState:UIControlStateNormal];
//        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:18]];
//        [_backButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
//        [parentView addSubview:_backButton];
//        CGRect bounds = [[UIScreen mainScreen] bounds];
//        
//        _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthPhone / 2),
//                                          bounds.size.height - kCaptureButtonHeightPhone - kCaptureButtonVerticalInsetPhone,
//                                          kCaptureButtonWidthPhone,
//                                          kCaptureButtonHeightPhone);
//        
//        _backButton.frame = CGRectMake((CGRectGetMinX(_captureButton.frame) - kBackButtonWidthPhone) / 2,
//                                       CGRectGetMinY(_captureButton.frame) + ((kCaptureButtonHeightPhone - kBackButtonHeightPhone) / 2),
//                                       kBackButtonWidthPhone,
//                                       kBackButtonHeightPhone);
//        
//        _buttonPanel.frame = CGRectMake(0,
//                                        CGRectGetMinY(_captureButton.frame) - kCaptureButtonVerticalInsetPhone,
//                                        bounds.size.width,
//                                        kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2));
//        
        
        // ******* End ********

		[self addSubview:overlayGraphicView];
//		[overlayGraphicView release];
		// Clear the background of the overlay:
        
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return NO;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


- (void)dealloc
{
//    [super dealloc];
    if (_overlayGraphic)
    {
//        [_overlayGraphic release];
    }
}


@end
