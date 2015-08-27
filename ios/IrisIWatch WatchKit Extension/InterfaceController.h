//
//  InterfaceController.h
//  IrisIWatch WatchKit Extension
//
//  Created by CloudMPower on 13/08/15.
//
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *recieveLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *sendButton;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *label1;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *label2;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *label3;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *label4;


@end
