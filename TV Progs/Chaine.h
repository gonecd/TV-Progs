//
//  Chaine.h
//  TV Progs
//
//  Created by Cyril Delamare on 01/11/12.
//  Copyright (c) 2012 Cd. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>

@class Prog;

@interface Chaine : NSObject <NSCoding> {
    NSString * idchaine;
    NSString * icone;
    NSString * nom;
    NSNumber * mesChaines;
}

@property (nonatomic, retain) NSString * idchaine;
@property (nonatomic, retain) NSString * icone;
@property (nonatomic, retain) NSString * nom;
@property (nonatomic, retain) NSNumber * mesChaines;


@end
