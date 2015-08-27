//
//  AccSummaryRowController.h
//  IrisIWatch
//
//  Created by CloudMPower on 17/08/15.
//
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface AccTransactionCreditRow : NSObject

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *amt;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *dateTime;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *trans;

@end

