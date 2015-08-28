//
//  OverlayView.m
//  AgileCapture
//
//
//  created by Incept Development
//  2011 Incept Development. All rights reserved

#import "OverlayBack.h"

@implementation OverlayBack

@synthesize overlayGraphic = _overlayGraphic;



- (id)initWithFrame:(CGRect)frame
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (self == [super initWithFrame:frame])
	{
        
        self.backgroundColor = [UIColor clearColor];
	
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
        
		
		[self addSubview:overlayGraphicView];
//		[overlayGraphicView release];
		
        
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
