//
//  CameraOverlayPlugin.m
//  CameraOVerlay
//
//  Created by CloudMPower on 10/04/13.
//
//

#import "CameraOverlayPlugin.h"





/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */


#import "CDVJpegHeaderWriter.h"
#import "Cordova/NSArray+Comparisons.h"
#import "Cordova/NSData+Base64.h"
#import "Cordova/NSDictionary+Extensions.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "OverlayView.h"
#import "OverlayBack.h"

#define radians(degrees) (degrees * M_PI/180)
#define CDV_PHOTO_PREFIX @"cdv_photo_"

static NSSet* org_apache_cordova_validArrowDirections;

UIView *_buttonPanel;
UIButton *_captureButton;
UIButton *_backButton;

static const CGFloat kCaptureButtonWidthPhone = 64;
static const CGFloat kCaptureButtonHeightPhone = 64;
static const CGFloat kBackButtonWidthPhone = 30;
static const CGFloat kBackButtonHeightPhone = 30;
static const CGFloat kCaptureButtonVerticalInsetPhone = 10;

static const CGFloat kCaptureButtonWidthTablet = 75;
static const CGFloat kCaptureButtonHeightTablet = 75;
static const CGFloat kBackButtonWidthTablet = 50;
static const CGFloat kBackButtonHeightTablet = 50;
static const CGFloat kCaptureButtonVerticalInsetTablet = 20;

@interface CameraOverlayPlugin ()

@property (readwrite, assign) BOOL hasPendingOperation;
@property (readwrite,assign)  BOOL cameraClicked;

@end

@implementation CameraOverlayPlugin

+ (void)initialize
{
    
    org_apache_cordova_validArrowDirections = [[NSSet alloc] initWithObjects:[NSNumber numberWithInt:UIPopoverArrowDirectionUp], [NSNumber numberWithInt:UIPopoverArrowDirectionDown], [NSNumber numberWithInt:UIPopoverArrowDirectionLeft], [NSNumber numberWithInt:UIPopoverArrowDirectionRight], [NSNumber numberWithInt:UIPopoverArrowDirectionAny], nil];
}

@synthesize hasPendingOperation, pickerController;

- (BOOL)popoverSupported
{
    return (NSClassFromString(@"UIPopoverController") != nil) &&
    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (void)takePictureRear:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    
    self.hasPendingOperation = NO;
    self.cameraClicked=NO;
    
    NSString* sourceTypeString = [arguments objectAtIndex:2];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera; // default
    if (sourceTypeString != nil) {
        sourceType = (UIImagePickerControllerSourceType)[sourceTypeString intValue];
    }
    
    bool hasCamera = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (!hasCamera) {
        NSLog(@"Camera.getPicture: source type %d not available.", sourceType);
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no camera available"];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }
    
    bool allowEdit = [[arguments objectAtIndex:7] boolValue];
    
    NSNumber* targetWidth = [NSNumber numberWithInt:1600];  //[arguments objectAtIndex:3];
    NSNumber* targetHeight = [NSNumber numberWithInt:1200]; //[arguments objectAtIndex:4];
    NSNumber* mediaValue = [arguments objectAtIndex:6];
    CDVMediaType mediaType = (mediaValue) ? [mediaValue intValue] : MediaTypePicture;
    
    CGSize targetSize = CGSizeMake(0, 0);
    if ((targetWidth != nil) && (targetHeight != nil)) {
        targetSize = CGSizeMake([targetWidth floatValue], [targetHeight floatValue]);
    }
    
    // If a popover is already open, close it; we only want one at a time.
    if (([[self pickerController] popoverController] != nil) && [[[self pickerController] popoverController] isPopoverVisible]) {
        [[[self pickerController] popoverController] dismissPopoverAnimated:YES];
        [[[self pickerController] popoverController] setDelegate:nil];
        [[self pickerController] setPopoverController:nil];
    }
    
    CDVCameraPicker* cameraPicker = [[CDVCameraPicker alloc] init];
    self.pickerController = cameraPicker;
    
    cameraPicker.delegate = self;
    cameraPicker.sourceType = sourceType;
    cameraPicker.allowsEditing = allowEdit; // THIS IS ALL IT TAKES FOR CROPPING - jm
    cameraPicker.callbackId = callbackId;
    cameraPicker.targetSize = targetSize;
    cameraPicker.cropToSize = NO;
    // we need to capture this state for memory warnings that dealloc this object
    cameraPicker.webView = self.webView;
    cameraPicker.popoverSupported = [self popoverSupported];
    
    cameraPicker.correctOrientation = [[arguments objectAtIndex:8] boolValue];
    cameraPicker.saveToPhotoAlbum = [[arguments objectAtIndex:9] boolValue];
    
    cameraPicker.encodingType = ([arguments objectAtIndex:5]) ? [[arguments objectAtIndex:5] intValue] : EncodingTypeJPEG;
    
    cameraPicker.quality = 40;
    //([arguments objectAtIndex:0]) ? [[arguments objectAtIndex:0] intValue] : 50;
    cameraPicker.returnType = ([arguments objectAtIndex:1]) ? [[arguments objectAtIndex:1] intValue] : DestinationTypeFileUri;
    
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        //Code added by Ravishankar V to suit the needs of the app.
        
        // toolbar - handy if you want to be able to exit from the image picker...
        UIToolbar *toolbar;
        
       
        
//*************  Changin the position of camera toolbar according to the device dimenstion **********
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            if (screenSize.height < 481.0f) {       /*  Resolution : 320x480   */
                /*Do iPhone Classic stuff here.*/
                toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 480-55, 320, 55)];
            } else if(screenSize.height < 569.0f){    /*  Resolution : 320x568   */
                /*Do iPhone 5 stuff here.*/
                toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 568-55, 320, 55)];
            } else if(screenSize.height < 668.0f){     /*  Resolution : 375 × 667   */
                /*Do iPhone 6 stuff here.*/
                toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 667-55, 375, 55)];
            } else if(screenSize.height < 737.0f){     /*  Resolution : 414 × 736   */
                /*Do iPhone 6 PLUS stuff here.*/
                toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 736-55, 414, 55)];
            }
        } else {
            /*Do iPad stuff here.*/
            toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 1024-55, 768, 55)];
        }
        
// ******* End ********

        toolbar.barStyle =  UIBarStyleDefault;
//        toolbar.clipsToBounds = YES;
//        toolbar.layer.borderWidth = 1;
//        toolbar.layer.borderColor = [[UIColor whiteColor] CGColor];
        toolbar.translucent = NO;
        NSArray *items=[NSArray arrayWithObjects:
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel  target:self action:@selector(cancel)],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera  target:self action:@selector(shootPicture)],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                        nil];
        [toolbar setItems:items];
        
        OverlayBack* overlay;
        // create the overlay view
        
        //************* iphone 5 device dimenstion settings **********
       
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height > 480.0f) {
                /*Do iPhone 5 stuff here.*/
                overlay=[[OverlayBack alloc] initWithFrame:CGRectMake(0, 0, 320, 568-44)];
            } else {
                /*Do iPhone Classic stuff here.*/
                overlay=[[OverlayBack alloc] initWithFrame:CGRectMake(0, 0, 320, 480-44)];
            }
        } else {
            /*Do iPad stuff here.*/
            overlay=[[OverlayBack alloc] initWithFrame:CGRectMake(0, 0, 768, 1024-44)];
        }
        
        // ******* End ********
        
        
        // important - it needs to be transparent so the camera preview shows through!
        overlay.opaque=NO;
        overlay.backgroundColor=[UIColor clearColor];
        
        // parent view for our overlay
       
        //************* iphone 5 device dimenstion settings **********
        
        UIView *parentView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height > 480.0f) {
                /*Do iPhone 5 stuff here.*/
                parentView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320, 568)];
            } else {
                /*Do iPhone Classic stuff here.*/
                parentView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320, 480)];
            }
        } else {
            /*Do iPad stuff here.*/
             parentView=[[UIView alloc] initWithFrame:CGRectMake(0,0,768, 1024)];
        }
        
        // ******* End ********
        
        [parentView addSubview:overlay];
  
//        [parentView addSubview:toolbar];
        
        // Device's screen size (ignoring rotation intentionally):
        CGSize screenSizeTest = [[UIScreen mainScreen] bounds].size;
        
        // iOS is going to calculate a size which constrains the 4:3 aspect ratio
        // to the screen size. We're basically mimicking that here to determine
        // what size the system will likely display the image at on screen.
        // NOTE: screenSize.width may seem odd in this calculation - but, remember,
        // the devices only take 4:3 images when they are oriented *sideways*.
        float cameraAspectRatio = 4.0 / 3.0;
        float imageWidth = floorf(screenSizeTest.width * cameraAspectRatio);
        float scale = ceilf((screenSizeTest.height / imageWidth) * 10.0) / 10.0;
        
        cameraPicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
        
        cameraPicker.cameraOverlayView=parentView;
        cameraPicker.showsCameraControls=NO;
        
        cameraPicker.allowsEditing =NO;
        cameraPicker.wantsFullScreenLayout = YES;
        
        ///////////////////////////////////////////////////////////////////////
        
        // We only allow taking pictures (no video) in this API.
        cameraPicker.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
        
        // We can only set the camera device if we're actually using the camera.
        NSNumber* cameraDirection = [command argumentAtIndex:11 withDefault:[NSNumber numberWithInteger:UIImagePickerControllerCameraDeviceRear]];
        cameraPicker.cameraDevice = (UIImagePickerControllerCameraDevice)[cameraDirection intValue];
    } else if (mediaType == MediaTypeAll) {
        cameraPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    } else {
        NSArray* mediaArray = [NSArray arrayWithObjects:(NSString*)(mediaType == MediaTypeVideo ? kUTTypeMovie : kUTTypeImage), nil];
        cameraPicker.mediaTypes = mediaArray;
    }
    
    if ([self popoverSupported] && (sourceType != UIImagePickerControllerSourceTypeCamera)) {
        if (cameraPicker.popoverController == nil) {
            cameraPicker.popoverController = [[NSClassFromString(@"UIPopoverController")alloc] initWithContentViewController:cameraPicker];
        }
        NSDictionary* options = [command.arguments objectAtIndex:10 withDefault:nil];
        [self displayPopover:options];
    } else {
        if ([self.viewController respondsToSelector:@selector(presentViewController:::)]) {
            [self.viewController presentViewController:cameraPicker animated:YES completion:nil];
        } else {
            [self.viewController presentModalViewController:cameraPicker animated:YES];
        }
    }
    self.hasPendingOperation = YES;
}


/*  takePicture arguments:
 * INDEX   ARGUMENT
 *  0       quality
 *  1       destination type
 *  2       source type
 *  3       targetWidth
 *  4       targetHeight
 *  5       encodingType
 *  6       mediaType
 *  7       allowsEdit
 *  8       correctOrientation
 *  9       saveToPhotoAlbum
 *  10      popoverOptions
 *  11      cameraDirection
 */
- (void)takePicture:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    
    self.hasPendingOperation = NO;
    self.cameraClicked=NO;
    
    NSString* sourceTypeString = [arguments objectAtIndex:2];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera; // default
    if (sourceTypeString != nil) {
        sourceType = (UIImagePickerControllerSourceType)[sourceTypeString intValue];
    }
    
    bool hasCamera = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (!hasCamera) {
        NSLog(@"Camera.getPicture: source type %d not available.", sourceType);
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no camera available"];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }
    
    bool allowEdit = [[arguments objectAtIndex:7] boolValue];
    NSNumber* targetWidth = [NSNumber numberWithInt:1600]; //[arguments objectAtIndex:3];
    NSNumber* targetHeight = [NSNumber numberWithInt:1200]; //[arguments objectAtIndex:4];
    NSNumber* mediaValue = [arguments objectAtIndex:6];
    CDVMediaType mediaType = (mediaValue) ? [mediaValue intValue] : MediaTypePicture;
    
    CGSize targetSize = CGSizeMake(0, 0);
    if ((targetWidth != nil) && (targetHeight != nil)) {
        targetSize = CGSizeMake([targetWidth floatValue], [targetHeight floatValue]);
    }
    
    // If a popover is already open, close it; we only want one at a time.
    if (([[self pickerController] popoverController] != nil) && [[[self pickerController] popoverController] isPopoverVisible]) {
        [[[self pickerController] popoverController] dismissPopoverAnimated:YES];
        [[[self pickerController] popoverController] setDelegate:nil];
        [[self pickerController] setPopoverController:nil];
    }
    
    CDVCameraPicker* cameraPicker = [[CDVCameraPicker alloc] init];
    self.pickerController = cameraPicker;
    
    cameraPicker.delegate = self;
    cameraPicker.sourceType = sourceType;
    cameraPicker.allowsEditing = allowEdit; // THIS IS ALL IT TAKES FOR CROPPING - jm
    cameraPicker.callbackId = callbackId;
    cameraPicker.targetSize = targetSize;
    cameraPicker.cropToSize = NO;
    // we need to capture this state for memory warnings that dealloc this object
    cameraPicker.webView = self.webView;
    cameraPicker.popoverSupported = [self popoverSupported];
    
    cameraPicker.correctOrientation = YES;
    cameraPicker.saveToPhotoAlbum = [[arguments objectAtIndex:9] boolValue];
    
    cameraPicker.encodingType = ([arguments objectAtIndex:5]) ? [[arguments objectAtIndex:5] intValue] : EncodingTypeJPEG;
    
    cameraPicker.quality =40;
    //([arguments objectAtIndex:0]) ? [[arguments objectAtIndex:0] intValue] : 50;
    cameraPicker.returnType = ([arguments objectAtIndex:1]) ? [[arguments objectAtIndex:1] intValue] : DestinationTypeFileUri;
    
//    -----------  Custom Button Panel -------------
    _buttonPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [_buttonPanel setBackgroundColor:[UIColor colorWithWhite:1 alpha:1.0f]];
    
    
    _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_captureButton setImage:[UIImage imageNamed:@"www/imgs/cameraoverlay/capture.png"] forState:UIControlStateNormal];
    [_captureButton setImage:[UIImage imageNamed:@"www/imgs/cameraoverlay/capture.png"] forState:UIControlStateSelected];
    [_captureButton setImage:[UIImage imageNamed:@"www/imgs/cameraoverlay/capture.png"] forState:UIControlStateHighlighted];
    [_captureButton addTarget:self action:@selector(shootPicture) forControlEvents:UIControlEventTouchUpInside];
    
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"www/imgs/cameraoverlay/cancel.png"] forState:UIControlStateNormal];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"www/imgs/cameraoverlay/cancel.png"] forState:UIControlStateHighlighted];
    [_backButton setTitle:@"" forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:18]];
    [_backButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
      
        CGRect bounds = [[UIScreen mainScreen] bounds];
    
        _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthPhone / 2),
                                      bounds.size.height - kCaptureButtonHeightPhone - kCaptureButtonVerticalInsetPhone,
                                      kCaptureButtonWidthPhone,
                                      kCaptureButtonHeightPhone);
    
        _backButton.frame = CGRectMake((CGRectGetMinX(_captureButton.frame) - kBackButtonWidthPhone) / 2,
                                   CGRectGetMinY(_captureButton.frame) + ((kCaptureButtonHeightPhone - kBackButtonHeightPhone) / 2),
                                   kBackButtonWidthPhone,
                                   kBackButtonHeightPhone);
    
        _buttonPanel.frame = CGRectMake(0,
                                    CGRectGetMinY(_captureButton.frame) - kCaptureButtonVerticalInsetPhone,
                                    bounds.size.width,
                                    kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2));
    }else{
        
        CGRect bounds = [[UIScreen mainScreen] bounds];
        
        _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthTablet / 2),
                                          bounds.size.height - kCaptureButtonHeightTablet - kCaptureButtonVerticalInsetTablet,
                                          kCaptureButtonWidthTablet,
                                          kCaptureButtonHeightTablet);
        
        _backButton.frame = CGRectMake((CGRectGetMinX(_captureButton.frame) - kBackButtonWidthTablet) / 2,
                                       CGRectGetMinY(_captureButton.frame) + ((kCaptureButtonHeightTablet - kBackButtonHeightTablet) / 2),
                                       kBackButtonWidthTablet,
                                       kBackButtonHeightTablet);
        
        _buttonPanel.frame = CGRectMake(0,
                                        CGRectGetMinY(_captureButton.frame) - kCaptureButtonVerticalInsetTablet,
                                        bounds.size.width,
                                        kCaptureButtonHeightTablet + (kCaptureButtonVerticalInsetTablet * 2));
    }
//    -----------  Custom Button Panel End ---------
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        //Code added by Ravishankar V to suit the needs of the app.
        
        // toolbar - handy if you want to be able to exit from the image picker...
        UIToolbar *toolbar;
    
//*************  Changin the position of camera toolbar according to the device dimenstion **********
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            
            if (screenSize.height < 481.0f) {       /*  Resolution : 320x480   */
                /*Do iPhone Classic stuff here.*/
                toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 480-55, 320, 55)];
            } else if(screenSize.height < 569.0f){    /*  Resolution : 320x568   */
                /*Do iPhone 5 stuff here.*/
                toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 568-55, 320, 55)];
            } else if(screenSize.height < 668.0f){     /*  Resolution : 375 × 667   */
                /*Do iPhone 6 stuff here.*/
                toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 667-55, 375, 55)];
            } else if(screenSize.height < 737.0f){     /*  Resolution : 414 × 736   */
                /*Do iPhone 6 PLUS stuff here.*/
                toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 736-55, 414, 55)];
            }
            
        } else {
            /*Do iPad stuff here.*/
            toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 1024-55, 768, 55)];
        }
        
// ******* End ********
        
        toolbar.barStyle =  UIBarStyleDefault;
        toolbar.translucent = NO;
        NSArray *items=[NSArray arrayWithObjects:
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel  target:self action:@selector(cancel)],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera  target:self action:@selector(shootPicture)],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                        nil];
        [toolbar setItems:items];
        
        OverlayView* overlay;
        // create the overlay view
        
        
        //************* iphone 5 device dimenstion settings **********
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height > 480.0f) {
                /*Do iPhone 5 stuff here.*/
                overlay=[[OverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 568-44)];
            } else {
                /*Do iPhone Classic stuff here.*/
                overlay=[[OverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-44)];
            }
        } else {
            /*Do iPad stuff here.*/
            overlay=[[OverlayView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024-44)];
        }
        
        // ******* End ********
        
        
        // important - it needs to be transparent so the camera preview shows through!
        overlay.opaque=NO;
        overlay.backgroundColor=[UIColor clearColor];
        
        // parent view for our overlay
        
        //************* iphone 5 device dimenstion settings **********
        
        UIView *parentView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height > 480.0f) {
                /*Do iPhone 5 stuff here.*/
                parentView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320, 568)];
            } else {
                /*Do iPhone Classic stuff here.*/
                parentView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320, 480)];
            }
        } else {
            /*Do iPad stuff here.*/
             parentView=[[UIView alloc] initWithFrame:CGRectMake(0,0,768, 1024)];
        }
        
        // ******* End ********
      
        [parentView addSubview:overlay];
        
//        [parentView addSubview:toolbar];
        [parentView addSubview:_buttonPanel];
        [parentView addSubview:_captureButton];
        [parentView addSubview:_backButton];
        
        // Device's screen size (ignoring rotation intentionally):
        CGSize screenSizeTest = [[UIScreen mainScreen] bounds].size;
        
        // iOS is going to calculate a size which constrains the 4:3 aspect ratio
        // to the screen size. We're basically mimicking that here to determine
        // what size the system will likely display the image at on screen.
        // NOTE: screenSize.width may seem odd in this calculation - but, remember,
        // the devices only take 4:3 images when they are oriented *sideways*.
        float cameraAspectRatio = 4.0 / 3.0;
        float imageWidth = floorf(screenSizeTest.width * cameraAspectRatio);
        float scale = ceilf((screenSizeTest.height / imageWidth) * 10.0) / 10.0;
        
        cameraPicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
        
        cameraPicker.cameraOverlayView=parentView;
        cameraPicker.showsCameraControls=NO;
        
        cameraPicker.allowsEditing =NO;
        cameraPicker.wantsFullScreenLayout = YES;
     
        ///////////////////////////////////////////////////////////////////////
        
        // We only allow taking pictures (no video) in this API.
        cameraPicker.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
        
        // We can only set the camera device if we're actually using the camera.
        NSNumber* cameraDirection = [command argumentAtIndex:11 withDefault:[NSNumber numberWithInteger:UIImagePickerControllerCameraDeviceRear]];
        cameraPicker.cameraDevice = (UIImagePickerControllerCameraDevice)[cameraDirection intValue];
    } else if (mediaType == MediaTypeAll) {
        cameraPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    } else {
        NSArray* mediaArray = [NSArray arrayWithObjects:(NSString*)(mediaType == MediaTypeVideo ? kUTTypeMovie : kUTTypeImage), nil];
        cameraPicker.mediaTypes = mediaArray;
    }
    
    if ([self popoverSupported] && (sourceType != UIImagePickerControllerSourceTypeCamera)) {
        if (cameraPicker.popoverController == nil) {
            cameraPicker.popoverController = [[NSClassFromString(@"UIPopoverController")alloc] initWithContentViewController:cameraPicker];
        }
        NSDictionary* options = [command.arguments objectAtIndex:10 withDefault:nil];
        [self displayPopover:options];
    } else {
        if ([self.viewController respondsToSelector:@selector(presentViewController:::)]) {
            [self.viewController presentViewController:cameraPicker animated:YES completion:nil];
        } else {
            [self.viewController presentModalViewController:cameraPicker animated:YES];
        }
    }
    self.hasPendingOperation = YES;
}

- (void)repositionPopover:(CDVInvokedUrlCommand*)command
{
    NSDictionary* options = [command.arguments objectAtIndex:0 withDefault:nil];
    
    [self displayPopover:options];
}

- (void)displayPopover:(NSDictionary*)options
{
    int x = 0;
    int y = 32;
    int width = 320;
    int height = 480;
    UIPopoverArrowDirection arrowDirection = UIPopoverArrowDirectionAny;
    
    if (options) {
        x = [options integerValueForKey:@"x" defaultValue:0];
        y = [options integerValueForKey:@"y" defaultValue:32];
        width = [options integerValueForKey:@"width" defaultValue:320];
        height = [options integerValueForKey:@"height" defaultValue:480];
        arrowDirection = [options integerValueForKey:@"arrowDir" defaultValue:UIPopoverArrowDirectionAny];
        if (![org_apache_cordova_validArrowDirections containsObject:[NSNumber numberWithInt:arrowDirection]]) {
            arrowDirection = UIPopoverArrowDirectionAny;
        }
    }
    
    [[[self pickerController] popoverController] setDelegate:self];
    [[[self pickerController] popoverController] presentPopoverFromRect:CGRectMake(x, y, width, height)
                                                                 inView:[self.webView superview]
                                               permittedArrowDirections:arrowDirection
                                                               animated:YES];
}

- (void)cleanup:(CDVInvokedUrlCommand*)command
{
    // empty the tmp directory
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSError* err = nil;
    BOOL hasErrors = NO;
    
    // clear contents of NSTemporaryDirectory
    NSString* tempDirectoryPath = NSTemporaryDirectory();
    NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
    NSString* fileName = nil;
    BOOL result;
    
    while ((fileName = [directoryEnumerator nextObject])) {
        // only delete the files we created
        if (![fileName hasPrefix:CDV_PHOTO_PREFIX]) {
            continue;
        }
        NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
        result = [fileMgr removeItemAtPath:filePath error:&err];
        if (!result && err) {
            NSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
            hasErrors = YES;
        }
    }
    
    CDVPluginResult* pluginResult;
    if (hasErrors) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:@"One or more files failed to be deleted."];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)popoverControllerDidDismissPopover:(id)popoverController
{
    // [ self imagePickerControllerDidCancel:self.pickerController ];	'
    UIPopoverController* pc = (UIPopoverController*)popoverController;
    
    [pc dismissPopoverAnimated:YES];
    pc.delegate = nil;
    if (self.pickerController && self.pickerController.callbackId && self.pickerController.popoverController) {
        self.pickerController.popoverController = nil;
        NSString* callbackId = self.pickerController.callbackId;
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no image selected"];   // error callback expects string ATM
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    self.hasPendingOperation = NO;
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    CDVCameraPicker* cameraPicker = (CDVCameraPicker*)picker;
    
    if (cameraPicker.popoverSupported && (cameraPicker.popoverController != nil)) {
        [cameraPicker.popoverController dismissPopoverAnimated:YES];
        cameraPicker.popoverController.delegate = nil;
        cameraPicker.popoverController = nil;
    } else {
        if ([cameraPicker respondsToSelector:@selector(presentingViewController)]) {
            [[cameraPicker presentingViewController] dismissModalViewControllerAnimated:YES];
        } else {
            [[cameraPicker parentViewController] dismissModalViewControllerAnimated:YES];
        }
    }
    
    CDVPluginResult* result = nil;
    
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // IMAGE TYPE
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        if (cameraPicker.returnType == DestinationTypeNativeUri) {
            NSString* nativeUri = [(NSURL*)[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nativeUri];
        } else {
            // get the image
            UIImage* image = nil;
            if (cameraPicker.allowsEditing && [info objectForKey:UIImagePickerControllerEditedImage]) {
                image = [info objectForKey:UIImagePickerControllerEditedImage];
            } else {
                image = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
            
            if (cameraPicker.saveToPhotoAlbum) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
            
            if (cameraPicker.correctOrientation) {
                image = [self imageCorrectedForCaptureOrientation:image];
            }
            
            UIImage* scaledImage = nil;
            
            if ((cameraPicker.targetSize.width > 0) && (cameraPicker.targetSize.height > 0)) {
                // if cropToSize, resize image and crop to target size, otherwise resize to fit target without cropping
                if (cameraPicker.cropToSize) {
                    scaledImage = [self imageByScalingAndCroppingForSize:image toSize:cameraPicker.targetSize];
                } else {
                    scaledImage = [self imageByScalingNotCroppingForSize:image toSize:cameraPicker.targetSize];
                }
            }
            
            NSData* data = nil;
            
            if (cameraPicker.encodingType == EncodingTypePNG) {
                data = UIImagePNGRepresentation(scaledImage == nil ? image : scaledImage);
            } else {
                data = UIImageJPEGRepresentation(scaledImage == nil ? image : scaledImage, cameraPicker.quality / 100.0f);
                
                /* splice loc */
                CDVJpegHeaderWriter* exifWriter = [[CDVJpegHeaderWriter alloc] init];
                NSString* headerstring = [exifWriter createExifAPP1:[info objectForKey:@"UIImagePickerControllerMediaMetadata"]];
                data = [exifWriter spliceExifBlockIntoJpeg:data withExifBlock:headerstring];
            }
            
            if (cameraPicker.returnType == DestinationTypeFileUri) {
                // write to temp directory and return URI
                // get the temp directory path
                NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
                NSError* err = nil;
                NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by apple (vs [NSFileManager defaultManager]) to be threadsafe
                // generate unique file name
                NSString* filePath;
                
                int i = 1;
                do {
                    filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_PHOTO_PREFIX, i++, cameraPicker.encodingType == EncodingTypePNG ? @"png":@"jpg"];
                } while ([fileMgr fileExistsAtPath:filePath]);
                
                // save file
                if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
                } else {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:filePath] absoluteString]];
                }
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[data base64EncodedString]];
            }
        }
    }
    // NOT IMAGE TYPE (MOVIE)
    else {
        NSString* moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] absoluteString];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:moviePath];
    }
    
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:cameraPicker.callbackId];
    }
    
    self.hasPendingOperation = NO;
    self.pickerController = nil;
}
-(void) shootPicture {
    
    if (self.cameraClicked == NO){
        self.cameraClicked=YES;
        [self.pickerController takePicture];
    }
    
    
}
// older api calls newer didFinishPickingMediaWithInfo
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo
{
    
 
    NSDictionary* imageInfo = [NSDictionary dictionaryWithObject:image forKey:UIImagePickerControllerOriginalImage];
    
    [self imagePickerController:picker didFinishPickingMediaWithInfo:imageInfo];
}


- (IBAction)cancel {
   
    // Don't pass current value to the edited object, just pop.
    [self.pickerController dismissModalViewControllerAnimated:YES];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no image selected"];   // error callback expects string ATM
    [self.commandDelegate sendPluginResult:result callbackId:self.pickerController.callbackId];
    
    self.hasPendingOperation = NO;
    self.pickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    CDVCameraPicker* cameraPicker = (CDVCameraPicker*)picker;
    
    if ([cameraPicker respondsToSelector:@selector(presentingViewController)]) {
        [[cameraPicker presentingViewController] dismissModalViewControllerAnimated:YES];
    } else {
        [[cameraPicker parentViewController] dismissModalViewControllerAnimated:YES];
    }
    // popoverControllerDidDismissPopover:(id)popoverController is called if popover is cancelled
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no image selected"];   // error callback expects string ATM
    [self.commandDelegate sendPluginResult:result callbackId:cameraPicker.callbackId];
    
    self.hasPendingOperation = NO;
    self.pickerController = nil;
}

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage*)anImage toSize:(CGSize)targetSize
{
    UIImage* sourceImage = anImage;
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        } else {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageCorrectedForCaptureOrientation:(UIImage*)anImage
{
    
    float rotation_radians = 0;
    bool perpendicular = false;
    
    switch ([anImage imageOrientation]) {
        case UIImageOrientationUp :
            rotation_radians = 0;
            break;
            
        case UIImageOrientationDown:
            rotation_radians = 180; // don't be scared of radians, if you're reading this, you're good at math
            break;
            
        case UIImageOrientationRight:
            rotation_radians = 0;
            perpendicular = true;
            break;
            
        case UIImageOrientationLeft:
            rotation_radians = 90;
            perpendicular = true;
            break;
            
        default:
            break;
    }
    if (perpendicular) {
        UIGraphicsBeginImageContext(CGSizeMake(anImage.size.height, anImage.size.width));
    }else{
       UIGraphicsBeginImageContext(CGSizeMake(anImage.size.width, anImage.size.height));
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Rotate around the center point
    if (perpendicular) {
        CGContextTranslateCTM(context, anImage.size.height / 2, anImage.size.width / 2);
    }else{
        CGContextTranslateCTM(context, anImage.size.width / 2, anImage.size.height / 2);
    }
    
    CGContextRotateCTM(context, radians(rotation_radians));
    
    CGContextScaleCTM(context, 1.0, -1.0);
    float width = perpendicular ? anImage.size.height : anImage.size.width;
    float height = perpendicular ? anImage.size.width : anImage.size.height;
    CGContextDrawImage(context, CGRectMake(-width / 2, -height / 2, width, height), [anImage CGImage]);
    
    // Move the origin back since the rotation might've change it (if its 90 degrees)
    if (perpendicular) {
        CGContextTranslateCTM(context, -anImage.size.height / 2, -anImage.size.width / 2);
    }
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageByScalingNotCroppingForSize:(UIImage*)anImage toSize:(CGSize)frameSize
{
    UIImage* sourceImage = anImage;
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = frameSize.width;
    CGFloat targetHeight = frameSize.height;
    CGFloat scaleFactor = 0.0;
    CGSize scaledSize = frameSize;
    
    if (CGSizeEqualToSize(imageSize, frameSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        // opposite comparison to imageByScalingAndCroppingForSize in order to contain the image within the given bounds
        if (widthFactor > heightFactor) {
            scaleFactor = heightFactor; // scale to fit height
        } else {
            scaleFactor = widthFactor; // scale to fit width
        }
        scaledSize = CGSizeMake(MIN(width * scaleFactor, targetWidth), MIN(height * scaleFactor, targetHeight));
    }
    
    UIGraphicsBeginImageContext(scaledSize); // this will resize
    
    [sourceImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)postImage:(UIImage*)anImage withFilename:(NSString*)filename toUrl:(NSURL*)url
{
    self.hasPendingOperation = YES;
    
    NSString* boundary = @"----BOUNDARY_IS_I";
    
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    
    NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField:@"Content-type"];
    
    NSData* imageData = UIImagePNGRepresentation(anImage);
    
    // adding the body
    NSMutableData* postBody = [NSMutableData data];
    
    // first parameter an image
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding : NSUTF8StringEncoding]];
    [postBody appendData:imageData];
    
    //	// second parameter information
    //	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //	[postBody appendData:[@"Content-Disposition: form-data; name=\"some_other_name\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //	[postBody appendData:[@"some_other_value" dataUsingEncoding:NSUTF8StringEncoding]];
    //	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req setHTTPBody:postBody];
    
    NSURLResponse* response;
    NSError* error;
    [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    //  NSData* result = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    //	NSString * resultStr =  [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease];
    
    self.hasPendingOperation = NO;
}

@end

@implementation CDVCameraPicker

@synthesize quality, postUrl;
@synthesize returnType;
@synthesize callbackId;
@synthesize popoverController;
@synthesize targetSize;
@synthesize correctOrientation;
@synthesize saveToPhotoAlbum;
@synthesize encodingType;
@synthesize cropToSize;
@synthesize webView;
@synthesize popoverSupported;

@end
