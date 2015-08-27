//
//  AccTransactionDebitRow.h
//  IrisIWatch
//
//  Created by CloudMPower on 18/08/15.
//
//


#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface AccTransactionDebitRow : NSObject

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *amt;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *dateTime;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *trans;

@end