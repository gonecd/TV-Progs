//
//  XMLToObjectParser.h
//  TV Progs
//
//  Created by Cyril Delamare on 10/11/12.
//  Copyright (c) 2012 Cd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLToObjectParser : NSObject  <NSXMLParserDelegate> {
	NSMutableArray *programmes;
	NSMutableArray *chaines;
    NSDateFormatter *dateFormatter;
	NSObject *item; // stands for any class
    NSInteger trieur;
    NSString *sauveValue;
	NSString *currentNodeName;
	NSMutableString *currentNodeContent;
}


- (NSArray *)programmes;
- (NSArray *)chaines;
- (id)parseXMLfromFile:(NSInputStream *)file
            parseError:(NSError **)error;

@end
