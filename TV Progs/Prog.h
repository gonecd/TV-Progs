//
//  Prog.h
//  TV Progs
//
//  Created by Cyril Delamare on 01/11/12.
//  Copyright (c) 2012 Cd. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>


@interface Prog : NSObject <NSCoding> {
    NSString * Aspect;
    NSString * Audio;
    NSString * Categorie;
    NSString * SousCategorie;
    NSInteger Annee;
    NSDate * debut;
    NSString * Resume;
    NSString * episode;
    NSDate * fin;
    NSString * icone;
    NSString * Inedit;
    NSString * Note;
    NSString * Qualite;
    NSString * Rating;
    NSString * SousTitre;
    NSString * Titre;
    NSString * chaine;
    //REVOLUTION NSInteger numChaine;
    NSString * logo;
    NSString * critique;
    NSMutableArray * cast;
}

@property (nonatomic, retain) NSString * Aspect;
@property (nonatomic, retain) NSString * Audio;
@property (nonatomic, retain) NSString * Categorie;
@property (nonatomic, retain) NSString * SousCategorie;
@property (nonatomic) NSInteger Annee;
@property (nonatomic, retain) NSDate * debut;
@property (nonatomic, retain) NSString * Resume;
@property (nonatomic, retain) NSString * episode;
@property (nonatomic, retain) NSDate * fin;
@property (nonatomic, retain) NSString * icone;
@property (nonatomic, retain) NSString * Inedit;
@property (nonatomic, retain) NSString * Note;
@property (nonatomic, retain) NSString * Qualite;
@property (nonatomic, retain) NSString * Rating;
@property (nonatomic, retain) NSString * SousTitre;
@property (nonatomic, retain) NSString * Titre;
@property (nonatomic, retain) NSString * chaine;
//REVOLUTION @property (nonatomic) NSInteger numChaine;
@property (nonatomic, retain) NSString * logo;
@property (nonatomic, retain) NSString * critique;
@property (nonatomic, retain) NSMutableArray * cast;

@end


@interface Casting : NSObject <NSCoding> {
    NSString * role;
    NSString * nom;
}

@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * nom;

@end
