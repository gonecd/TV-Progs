//
//  Chaine.m
//  TV Progs
//
//  Created by Cyril Delamare on 01/11/12.
//  Copyright (c) 2012 Cd. All rights reserved.
//

#import "Chaine.h"


@implementation Chaine

@synthesize idchaine;
@synthesize icone;
@synthesize nom;
@synthesize mesChaines;


-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject: idchaine forKey:@"idchaine"];
    [coder encodeObject: icone forKey:@"icone"];
    [coder encodeObject: nom forKey:@"nom"];
    [coder encodeObject: mesChaines forKey:@"mesChaines"];
}

-(id) initWithCoder:(NSCoder *) coder {
    if (self = [super init]) {
        idchaine = [coder decodeObjectForKey:@"idchaine"];
        icone = [coder decodeObjectForKey:@"icone"];
        nom = [coder decodeObjectForKey:@"nom"];
        mesChaines = [coder decodeObjectForKey:@"mesChaines"];
    }
    return self;
}

@end
