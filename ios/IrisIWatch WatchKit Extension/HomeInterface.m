//
//  homeController.m
//  IrisIWatch
//
//  Created by CloudMPower on 14/08/15.
//
//

#import "HomeInterface.H"
#import "AccTransactionCreditRow.h"
#import "AccTransactionDebitRow.h"

@interface HomeInterface()

@end

@implementation HomeInterface

@synthesize prodName;
@synthesize accName;
@synthesize accNo;
@synthesize availBal;

@synthesize accTransactionTable;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    
//    NSLog(@"%@" , context);
    NSObject *accObj = context;
    [self renderAccs:accObj];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self renderTrans];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void) renderAccs : (NSObject*)account{

    NSString *productName = [account valueForKey:@"productName"];
    NSString *accountType = [account valueForKey:@"accountType"];
    NSString *accountNO = [account valueForKey:@"accountNo"];
    NSString *availableBalance = [account valueForKey:@"availableBalance"];
        
    NSLog(@"Account Type %@" , accountType);

    [prodName setText:productName];
    [accName setText:accountType];
    [accNo setText:accountNO];
    [availBal setText:availableBalance];
    
    
    
}

- (void) renderTrans {
    NSDictionary *t1 = @{
                         @"amt" : [NSString stringWithFormat:@"-500.00"],
                         @"date" : [NSString stringWithFormat:@"06/20 4:30"],
                         @"transName" : [NSString stringWithFormat:@"VSoft Corporation"],
                         @"type" : [NSString stringWithFormat:@"debit"]
    };
    NSDictionary *t2 = @{
                         @"amt" : [NSString stringWithFormat:@"+50,000.00"],
                         @"date" : [NSString stringWithFormat:@"06/30 23.59"],
                         @"transName" : [NSString stringWithFormat:@"Big Tree Pvt. Ltd"],
                         @"type" : [NSString stringWithFormat:@"credit"]
                         };

    NSDictionary *t3 = @{
                         @"amt" : [NSString stringWithFormat:@"-2,310.25"],
                         @"date" : [NSString stringWithFormat:@"08/05 10:55"],
                         @"transName" : [NSString stringWithFormat:@"Car Mechanics"],
                         @"type" : [NSString stringWithFormat:@"debit"]
                         };
    NSDictionary *t4 = @{
                         @"amt" : [NSString stringWithFormat:@"-1,400.15"],
                         @"date" : [NSString stringWithFormat:@"10/14 11:30"],
                         @"transName" : [NSString stringWithFormat:@"Walmart"],
                         @"type" : [NSString stringWithFormat:@"debit"]
                         };

    NSDictionary *t5 = @{
                         @"amt" : [NSString stringWithFormat:@"-24.00"],
                         @"date" : [NSString stringWithFormat:@"11/26 13:30"],
                         @"transName" : [NSString stringWithFormat:@"Starbucks"],
                         @"type" : [NSString stringWithFormat:@"debit"]
                         };

    NSMutableArray *transArray = [NSMutableArray arrayWithObjects: t1, t2, t3, t4, t5, nil];
    
//        *-**************************------------------------------
    NSMutableArray *rowTypesList = [NSMutableArray array];

    
    for (NSInteger i = 0; i < transArray.count; i++){
        
        NSDictionary *singleTran = transArray[i];
        NSString *type = singleTran[@"type"];
        if([type isEqualToString:@"credit"]){
            [rowTypesList addObject:@"AccTransactionCreditRow"];
        }else{
            [rowTypesList addObject:@"AccTransactionDebitRow"];
        }
    }
    [accTransactionTable setRowTypes:rowTypesList];
    
    for (NSInteger j = 0; j < accTransactionTable.numberOfRows; j++)
    {
        NSObject *row = [accTransactionTable rowControllerAtIndex:j];
        NSDictionary *singleTran = transArray[j];
 
        if ([row isKindOfClass:[AccTransactionCreditRow class]]){
            
            AccTransactionCreditRow *creditRow = (AccTransactionCreditRow *) row;
            [creditRow.amt setText:singleTran[@"amt"]];
            [creditRow.dateTime setText:singleTran[@"date"]];
            [creditRow.trans setText:singleTran[@"transName"]];
            
        }else{

            AccTransactionDebitRow *debitRow = (AccTransactionDebitRow *) row;
            [debitRow.amt setText:singleTran[@"amt"]];
            [debitRow.dateTime setText:singleTran[@"date"]];
            [debitRow.trans setText:singleTran[@"transName"]];
            
        }
        
    
    }
}

@end
