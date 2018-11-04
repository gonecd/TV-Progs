//
//  Prog.m
//  TV Progs
//
//  Created by Cyril Delamare on 01/11/12.
//  Copyright (c) 2012 Cd. All rights reserved.
//

#import "Prog.h"


@implementation Prog

@synthesize Aspect;
@synthesize Audio;
@synthesize Categorie;
@synthesize SousCategorie;
@synthesize Annee;
@synthesize debut;
@synthesize Resume;
@synthesize episode;
@synthesize fin;
@synthesize icone;
@synthesize Inedit;
@synthesize Note;
@synthesize Qualite;
@synthesize Rating;
@synthesize SousTitre;
@synthesize Titre;
@synthesize chaine;
//REVOLUTION @synthesize numChaine;
@synthesize logo;
@synthesize critique;
@synthesize cast;


-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:Aspect forKey:@"Aspect"];
    [coder encodeObject:Audio forKey:@"Audio"];
    [coder encodeObject:Categorie forKey:@"Categorie"];
    [coder encodeObject:SousCategorie forKey:@"SousCategorie"];
    [coder encodeInteger:Annee forKey:@"Annee"];
    [coder encodeObject:debut forKey:@"debut"];
    [coder encodeObject:Resume forKey:@"Resume"];
    [coder encodeObject:episode forKey:@"episode"];
    [coder encodeObject:fin forKey:@"fin"];
    [coder encodeObject:icone forKey:@"icone"];
    [coder encodeObject:Inedit forKey:@"Inedit"];
    [coder encodeObject:Note forKey:@"Note"];
    [coder encodeObject:Qualite forKey:@"Qualite"];
    [coder encodeObject:Rating forKey:@"Rating"];
    [coder encodeObject:SousTitre forKey:@"SousTitre"];
    [coder encodeObject:Titre forKey:@"Titre"];
    [coder encodeObject:chaine forKey:@"chaine"];
    //REVOLUTION [coder encodeInteger:numChaine forKey:@"numChaine"];
    [coder encodeObject:logo forKey:@"logo"];
    [coder encodeObject:critique forKey:@"critique"];
    [coder encodeObject:cast forKey:@"cast"];
}

-(id) initWithCoder:(NSCoder *) coder {
    if (self = [super init]) {
        Aspect = [coder decodeObjectForKey:@"Aspect"];
        Audio = [coder decodeObjectForKey:@"Audio"];
        Categorie = [coder decodeObjectForKey:@"Categorie"];
        SousCategorie = [coder decodeObjectForKey:@"SousCategorie"];
        Annee = [coder decodeIntegerForKey:@"Annee"];
        debut = [coder decodeObjectForKey:@"debut"];
        Resume = [coder decodeObjectForKey:@"Resume"];
        episode = [coder decodeObjectForKey:@"episode"];
        fin = [coder decodeObjectForKey:@"fin"];
        icone = [coder decodeObjectForKey:@"icone"];
        Inedit = [coder decodeObjectForKey:@"Inedit"];
        Note = [coder decodeObjectForKey:@"Note"];
        Qualite = [coder decodeObjectForKey:@"Qualite"];
        Rating = [coder decodeObjectForKey:@"Rating"];
        SousTitre = [coder decodeObjectForKey:@"SousTitre"];
        Titre = [coder decodeObjectForKey:@"Titre"];
        chaine = [coder decodeObjectForKey:@"chaine"];
        //REVOLUTION numChaine = [coder decodeIntegerForKey:@"numChaine"];
        logo = [coder decodeObjectForKey:@"logo"];
        critique = [coder decodeObjectForKey:@"critique"];
        cast = [coder decodeObjectForKey:@"cast"];
    }
    return self;
}

@end





@implementation Casting

@synthesize role;
@synthesize nom;

-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:role forKey:@"role"];
    [coder encodeObject:nom forKey:@"nom"];
}

-(id) initWithCoder:(NSCoder *) coder {
    if (self = [super init]) {
        role = [coder decodeObjectForKey:@"role"];
        nom = [coder decodeObjectForKey:@"nom"];
    }
    return self;
}


@end
