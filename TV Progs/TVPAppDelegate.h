//
//  TVPAppDelegate.h
//  TV Progs
//
//  Created by Cyril Delamare on 01/11/12.
//  Copyright (c) 2012 Cd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLToObjectParser.h"

@interface TVPAppDelegate : NSObject <NSApplicationDelegate>  {
    NSMutableArray *allProgs;
    NSArray *progs;
    NSMutableArray *allChaines;
    NSMutableArray *mesChaines;
    NSMutableArray *mesFiltres;
    NSImage *mire;
    NSString *homeApp;
    NSString *homeFile;
    XMLToObjectParser *myParser;
}

    @property (assign) IBOutlet NSWindow *window;

    // Objets graphiques zone en haut à gauche
    @property (weak) IBOutlet NSTextField *uiCatalogueDebut;
    @property (weak) IBOutlet NSTextField *uiCatalogFin;
    @property (weak) IBOutlet NSTextField *uiCatalogChaines;
    @property (weak) IBOutlet NSTextField *uiCatalogProgs;
    @property (weak) IBOutlet NSTextField *uiNbChaines;
    @property (weak) IBOutlet NSTextField *uiNbProgs;

    @property (weak) IBOutlet NSPopUpButton *uiCatalogSource;
    @property (weak) IBOutlet NSProgressIndicator *uiProgressLoad;
    @property (weak) IBOutlet NSProgressIndicator *uiProgressAnalyse;


    @property (weak) IBOutlet NSScrollView *uiListechaines;
    @property (unsafe_unretained) IBOutlet NSWindow *ecranChaines;


    // Objets graphiques de définition des flitres
    @property (weak) IBOutlet NSPopUpButton *uiCategories;
    @property (weak) IBOutlet NSPopUpButton *uiSousCategories;
    @property (weak) IBOutlet NSMatrix *uiQuand;
    @property (weak) IBOutlet NSMatrix *uiHoraire;
    @property (weak) IBOutlet NSTextField *uiFmot;
    @property (weak) IBOutlet NSButton *uiFtitre;
    @property (weak) IBOutlet NSButton *uiFsoustitre;
    @property (weak) IBOutlet NSButton *uiFresume;
    @property (weak) IBOutlet NSImageView *uiSurround;
    @property (weak) IBOutlet NSImageView *uiDolby;

    @property (unsafe_unretained) IBOutlet NSTextView *uiLogger;
    @property (weak) IBOutlet NSPredicateEditor *uiRegles;
    @property (weak) IBOutlet NSTabView *uiTabul;

    @property (weak) IBOutlet NSTableView *uiTableau;
    @property (weak) IBOutlet NSTableView *uiTabChaines;
    @property (weak) IBOutlet NSTableView *uiFiltres;

    // Objets graphiques zone en bas à droite
    @property (weak) IBOutlet NSImageView *uiImage;
    @property (weak) IBOutlet NSImageView *uiChaine;
    @property (weak) IBOutlet NSTextField *uiTitre;
    @property (weak) IBOutlet NSTextField *uiSoustitre;
    @property (weak) IBOutlet NSTextField *uiDescription;
    @property (weak) IBOutlet NSTextField *uiDebut;
    @property (weak) IBOutlet NSTextField *uiFin;
    @property (weak) IBOutlet NSTextField *uiDate;
    @property (weak) IBOutlet NSImageView *uiCSA10;
    @property (weak) IBOutlet NSImageView *uiCSA12;
    @property (weak) IBOutlet NSImageView *uiCSA16;
    @property (weak) IBOutlet NSImageView *uiCSA18;
    @property (weak) IBOutlet NSImageView *uiCSAP;
    @property (weak) IBOutlet NSImageView *uiHD;
    @property (weak) IBOutlet NSImageView *uiLQ;
    @property (weak) IBOutlet NSImageView *uiStar1;
    @property (weak) IBOutlet NSImageView *uiStar2;
    @property (weak) IBOutlet NSImageView *uiStar3;
    @property (weak) IBOutlet NSImageView *uiStar4;
    @property (weak) IBOutlet NSImageView *uiStar5;
    @property (weak) IBOutlet NSImageView *ui43;
    @property (weak) IBOutlet NSImageView *ui169;
    @property (weak) IBOutlet NSTextField *uiAnnee;
    @property (weak) IBOutlet NSTextField *uiCasting;


    // Méthodes de l'IHM
    - (IBAction)importer:(id)sender;
    - (IBAction)changeCategorie:(id)sender;
    - (IBAction)saveAction:(id)sender;
    - (IBAction)rowSelected:(id)sender;
    - (IBAction)sauverFiltre:(id)sender;
    - (IBAction)defiltrer:(id)sender;
    - (IBAction)downloadFile:(id)sender;
    - (IBAction)changeCatalogue:(id)sender;
    - (IBAction)filtrePredicate:(id)sender;
    - (IBAction)supprimerPredicat:(id)sender;

    - (IBAction)afficheChaines:(id)sender;
    - (IBAction)validerChaines:(id)sender;
    - (IBAction)annulerChaines:(id)sender;


    - (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
    - (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
    - (void)tableView:(NSTableView*)aTableView setObjectValue:(id)val forTableColumn:(NSTableColumn*)aTableColumn row:(NSInteger)rowIndex;


- (IBAction)f1:(id)sender;
- (IBAction)f2:(id)sender;
- (IBAction)f3:(id)sender;


    @property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    @property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
    @property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
