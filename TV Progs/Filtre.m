//
//  Filtre.m
//  TV Progs
//
//  Created by Cyril Delamare on 24/03/13.
//  Copyright (c) 2013 Cd. All rights reserved.
//

#import "Filtre.h"

@implementation Filtre


@synthesize NomFiltre;
@synthesize Predicat;


-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:NomFiltre forKey:@"NomFiltre"];
    [coder encodeObject:Predicat forKey:@"Predicat"];
}

-(id) initWithCoder:(NSCoder *) coder {
    if (self = [super init]) {
        NomFiltre = [coder decodeObjectForKey:@"NomFiltre"];
        Predicat = [coder decodeObjectForKey:@"Predicat"];
    }
    return self;
}


@end
