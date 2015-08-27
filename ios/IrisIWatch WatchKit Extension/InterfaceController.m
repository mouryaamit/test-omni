//
//  InterfaceController.m
//  IrisIWatch WatchKit Extension
//
//  Created by CloudMPower on 13/08/15.
//
//

#import "InterfaceController.h"
#import "MMWormhole.h"
#import "SBJSON/SBJson4.h"
#import "HomeInterface.h"


@interface InterfaceController()
@property (nonatomic, strong) MMWormhole* wormhole;
@property (strong) SBJson4Parser *parser;
@end

@implementation InterfaceController

@synthesize recieveLabel;
@synthesize sendButton;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self initMessagePortal];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
        [super willActivate];
//    [ self openHostApp];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)initMessagePortal {
    NSLog(@"Init Message Portal");

    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.vsoft.omni"
                                                    optionalDirectory:nil];
   
    
    [self.wormhole listenForMessageWithIdentifier:@"sendToWatchEmpty" listener:^(id message) {
        NSLog(@"Message Recieved");
//        int i = rand()%100+1;
//        NSString* str = [NSString stringWithFormat:@"%i",i];
//        [recieveLabel setText:str];
        [recieveLabel setHidden:false];
        [sendButton setHidden:false];
    }];
    
    [self.wormhole listenForMessageWithIdentifier:@"sendToWatchData" listener:^(id message) {
        NSLog( @"%@", message);
        
//        [recieveLabel setHidden:true];
//        [sendButton setHidden:true];
       
        NSString *messageString = (NSString*)message;
        [self parseJSON:messageString];
        
    }];
    
}

- (IBAction)getAccData{
    NSLog(@"Clicked");
//    [self test];

    [self.wormhole passMessageObject:@"GetAccountDetails" identifier:@"requestData"];

//    [self presentControllerWithNames:view contexts:list];
    
//    [self pushControllerWithName:@"HomeInterfaceController" context:nil];
    
}

- (void) test {
        NSString *jsonStr = @"[{\"productName\":\"Loan1\",\"accountType\":\"Checkings1\",\"accountNo\":\"****5547\",\"availableBalance\":\"5001.02\"},{\"productName\":\"Loan2\",\"accountType\":\"Checkings2\",\"accountNo\":\"****5547\",\"availableBalance\":\"5001.02\"},{\"productName\":\"Loan3\",\"accountType\":\"Checkings3\",\"accountNo\":\"****5547\",\"availableBalance\":\"5001.02\"}]";
    [self parseJSON:jsonStr];
}

- (void) renderAccViews: (NSMutableArray *) accColl {
    
    NSMutableArray *viewNameColl = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < accColl.count; i++){
        NSString *viewName = @"HomeInterface";
        [viewNameColl addObject: viewName];
    }
    [self presentControllerWithNames:viewNameColl contexts:accColl];
}

- (void) parseJSON : (NSString*) jsonString {
    NSMutableArray *accList = [NSMutableArray array];
   
    id block = ^(id item, BOOL *stop) {
        [accList addObject:item];
        
        //            NSString * test = [item objectForKey:@"accountNo"];
        //            NSLog(@"TEST IS %@", test);
        //            BOOL isArray = [item isKindOfClass:[NSArray class]];
        //            NSLog(@"Found: %@", isArray ? @"Array" : @"Object");
        
    };
    id eh = ^(NSError *error) {
        NSLog(@"OOPS: %@", error);
    };
    self.parser = [SBJson4Parser unwrapRootArrayParserWithBlock:block
                                                   errorHandler:eh];

    id data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    //        [self.parser parse:data];
    switch ([self.parser parse:data]) {
        case SBJson4ParserError:
            NSLog(@"Found an error");
            self.parser = nil;
            break;
        case SBJson4ParserComplete:
            NSLog(@"Complete");
            [self renderAccViews: accList];
            break;
        case SBJson4ParserStopped:
            self.parser = nil;
            NSLog(@"Stopped");
            break;
        case SBJson4ParserWaitingForData:
            NSLog(@"Waiting for more data!");
            break;
    }
}


- (void) openHostApp {
//    [WKInterfaceController openParentApplication:@{@"action":@"toggleStatus"} reply:^(NSDictionary *replyInfo, NSError *error)
//     {
//         NSLog(@"%@ %@",replyInfo, error);
//     }];
    [WKInterfaceController openParentApplication:[NSDictionary dictionaryWithObject:@"red" forKey:@"color"] reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"replyInfo %@",replyInfo);
        NSLog(@"Error: %@",error);
    }];
}

//
//- (void) renderAccs : (NSMutableArray*)accDetails {
//    
//    NSMutableArray *rowTypesList = [NSMutableArray array];
//    
//    for (NSInteger i = 0; i < accDetails.count; i++){
//        [rowTypesList addObject:@"AccSummaryRow"];
//    }
//    
//    [accSummaryTable setRowTypes:rowTypesList];
//    
//    for (NSInteger i = 0; i < accDetails.count; i++)
//    {
//        NSObject *row = [accSummaryTable rowControllerAtIndex:i];
//        NSObject *account = [accDetails objectAtIndex:i];
//         NSLog(@"Account %@", account);
//        NSString *productName = [account valueForKey:@"productName"];
//        NSString *accountType = [account valueForKey:@"accountType"];
//        NSString *accountNO = [account valueForKey:@"accountNo"];
//        NSString *availableBalance = [account valueForKey:@"availableBalance"];
//       
//        BOOL isArray = [account isKindOfClass:[NSArray class]];
//         NSLog(@"Found: %@", isArray ? @"Array" : @"Object");
//        
//        AccSummaryRow *accSummSingleRow = (AccSummaryRow *) row;
//        [accSummSingleRow.prodName setText:productName];
//        [accSummSingleRow.accName setText:accountType];
//        [accSummSingleRow.accNo setText:accountNO];
//        [accSummSingleRow.availBal setText:availableBalance];
//        
//    }
//}



@end



