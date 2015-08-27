//
//  homeController.h
//  IrisIWatch
//
//  Created by CloudMPower on 14/08/15.
//
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface HomeInterface : WKInterfaceController

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *prodName;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *accName;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *accNo;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *availBal;

@property (nonatomic, weak) IBOutlet WKInterfaceTable *accTransactionTable;

@end