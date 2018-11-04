//
//  Filtre.h
//  TV Progs
//
//  Created by Cyril Delamare on 24/03/13.
//  Copyright (c) 2013 Cd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filtre : NSObject <NSCoding> {
    
    NSString *NomFiltre;
    NSString *Predicat;
}

@property (nonatomic, retain) NSString *NomFiltre;
@property (nonatomic, retain) NSString *Predicat;

@end
