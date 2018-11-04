//
//  TVPAppDelegate.m
//  TV Progs
//
//  Created by Cyril Delamare on 01/11/12.
//  Copyright (c) 2012 Cd. All rights reserved.
//

#import "TVPAppDelegate.h"
#import "Prog.h"
#import "Chaine.h"
#import "Filtre.h"
#import "MyRowTemplate.h"


@implementation TVPAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Initialisation de l'application
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   
    // Initialisation des variables
	allProgs = [[NSMutableArray alloc] init];
	progs = [[NSMutableArray alloc] init];
	mesFiltres = [[NSMutableArray alloc] init];
	mesChaines = [[NSMutableArray alloc] init];
    homeApp = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    homeFile = [[paths objectAtIndex:0] stringByAppendingString:@"/TV Progs/"];
    mire = [[NSImage alloc] initWithContentsOfFile:[homeApp stringByAppendingString:@"mire.jpg"]];
    NSDate * stat = [NSDate date];
	   
    // Initialisation du tableau de chaines
    allChaines = [[NSMutableArray alloc] init];
    for(int i = 0; i < 5000; i++) {
		Chaine *new = [[Chaine alloc] init];
		[allChaines addObject:new];
    }
    
    //Création de l'arborescence si elle n'existe pas
    if (![[NSFileManager defaultManager] fileExistsAtPath:homeFile]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:homeFile withIntermediateDirectories:YES attributes:nil error:nil];

        // Download des fichiers data
        [self loadOnWeb:@"http://kevinpato.free.fr/xmltv/download/tnt.zip" Vers:@"/tmp/tnt.zip"];
        [self unzipFile:@"/tmp/tnt.zip"];
        [self loadOnWeb:@"http://kevinpato.free.fr/xmltv/download/complet.zip" Vers:@"/tmp/complet.zip"];
        [self unzipFile:@"/tmp/complet.zip"];
        
        [self loggue:[NSString stringWithFormat:@"First run - initialisation [%.2f sec]\n", [[NSDate date] timeIntervalSinceDate:stat]]];
        stat = [NSDate date];
    }
    
    // Chargement des filtres sauvegardés
    if ([[NSFileManager defaultManager] fileExistsAtPath:[homeFile stringByAppendingString:@"TvProgs.Filtres"]]) { mesFiltres = [NSKeyedUnarchiver unarchiveObjectWithFile:[homeFile stringByAppendingString:@"TvProgs.Filtres"]]; }
    [self loggue:[NSString stringWithFormat:@"Filtres chargés : %lu filtres [%.2f sec]\n", [mesFiltres count], [[NSDate date] timeIntervalSinceDate:stat]]];
    //Filtre *fil;
    //for (fil in mesFiltres) { NSLog(@"Filtre : %@", fil.Predicat); }
    
    // Charger le fichier xml et les structures de données
    [self parseFichier:[homeFile stringByAppendingString:@"complet.xml"]];
    [self importer:self];
    
    
    [self initPredicates];
    [[self uiTableau] setDataSource:(id)self];
    [[self uiTableau] setDelegate:(id)self];
    [[self uiTabChaines] setDataSource:(id)self];
    [[self uiTabChaines] setDelegate:(id)self];
    [[self uiFiltres] setDataSource:(id)self];
    [[self uiFiltres] setDelegate:(id)self];
}

-(void)initPredicates {
    
    // Gestion des règles dynamiques
    [self.uiRegles setObjectValue:[NSPredicate predicateWithFormat:@"(Titre contains '' AND SousTitre contains '')"]];
    
    NSArray *templates;
    NSArray *keyPaths;
    NSArray *operators = [NSArray arrayWithObjects:[NSNumber numberWithInteger:NSEqualToPredicateOperatorType], [NSNumber numberWithInteger:NSNotEqualToPredicateOperatorType], nil];
    NSMutableArray *listecateg = [[NSMutableArray alloc] init];
    NSArray * tableau;
    NSString * item;
    NSPredicateEditorRowTemplate *template;
    
    // Règle pour les catégories
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"Categorie"], nil];
    for (item in [self.uiCategories itemTitles]) { [listecateg addObject:[NSExpression expressionForConstantValue:item] ]; }
    [listecateg removeObjectAtIndex:0];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:listecateg modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [[self.uiRegles rowTemplates] arrayByAddingObject:template];
    
    // Règle pour les sous catégories
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"SousCategorie"], nil];
    [listecateg removeAllObjects];
    for (item in [self.uiSousCategories itemTitles]) { [listecateg addObject:[NSExpression expressionForConstantValue:item] ]; }
    [listecateg removeObjectAtIndex:0];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:listecateg modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template];
    
    // Règle pour les notes
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"Note"], nil];
    tableau = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"1/5"], [NSExpression expressionForConstantValue:@"2/5"], [NSExpression expressionForConstantValue:@"3/5"],
               [NSExpression expressionForConstantValue:@"4/5"], [NSExpression expressionForConstantValue:@"5/5"], [NSExpression expressionForConstantValue:@"?"], nil ];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:tableau modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template];
    
    // Règle pour les notes
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"Rating"], nil];
    tableau = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"Tout public"], [NSExpression expressionForConstantValue:@"-10"], [NSExpression expressionForConstantValue:@"-12"],
               [NSExpression expressionForConstantValue:@"-16"], [NSExpression expressionForConstantValue:@"-18"], nil ];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:tableau modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template];
    
    // Règle pour l'aspect
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"Aspect"], nil];
    tableau = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"16:9"], [NSExpression expressionForConstantValue:@"4:3"], nil ];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:tableau modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template];
    
    // Règle pour la qualité
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"Qualite"], nil];
    tableau = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"HDTV"], [NSExpression expressionForConstantValue:@"LQ"], nil ];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:tableau modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template];
    
    // Règle pour l'audio
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"Audio"], nil];
    tableau = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"dolby"], [NSExpression expressionForConstantValue:@"surround"],
               [NSExpression expressionForConstantValue:@"bilingual"], [NSExpression expressionForConstantValue:@"?"], nil ];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:tableau modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template];
    
    // Règle pour inédit/rediffusion
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"Inedit"], nil];
    tableau = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"inedit"], [NSExpression expressionForConstantValue:@"rediffusion"], [NSExpression expressionForConstantValue:@"?"], nil ];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:tableau modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template];
    
    // Règle pour le casting
    operators = [NSArray arrayWithObjects:[NSNumber numberWithInteger:NSContainsPredicateOperatorType], nil];
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"cast.role"], nil];
    tableau = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"Acteur"], [NSExpression expressionForConstantValue:@"Réalisateur"], [NSExpression expressionForConstantValue:@"Auteur"],
               [NSExpression expressionForConstantValue:@"Invité"], [NSExpression expressionForConstantValue:@"Compositeur"], [NSExpression expressionForConstantValue:@"Présentateur"], nil ];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:tableau modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template];
    
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"cast.nom"], nil];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressionAttributeType:NSStringAttributeType modifier:NSAnyPredicateModifier operators:operators options:(NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption)];
    templates = [templates arrayByAddingObject:template];
    
    // Règle pour les dates
    MyRowTemplate *template2;
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"debut"], nil];
    operators = [NSArray arrayWithObjects:[NSNumber numberWithInteger:NSMatchesPredicateOperatorType], nil];
    tableau = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"Maintenant"], [NSExpression expressionForConstantValue:@"Aujourd'hui"], [NSExpression expressionForConstantValue:@"Demain"], [NSExpression expressionForConstantValue:@"Ce soir"], [NSExpression expressionForConstantValue:@"Ce soir (2ème partie)"], [NSExpression expressionForConstantValue:@"Demain soir"], [NSExpression expressionForConstantValue:@"Demain soir (2ème partie)"], nil ];
    template2 = [[MyRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressions:tableau modifier:NSDirectPredicateModifier operators:operators options:nil];
    templates = [templates arrayByAddingObject:template2];
    
    operators = [NSArray arrayWithObjects:[NSNumber numberWithInteger:NSLessThanPredicateOperatorType], [NSNumber numberWithInteger:NSGreaterThanPredicateOperatorType], nil];
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"debut"], nil];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressionAttributeType:NSDateAttributeType modifier:NSDirectPredicateModifier operators:operators options:nil];
    // PLANTE A LA COMPIL [[[template templateViews] objectAtIndex:2] setDatePickerElements:(NSHourMinuteDatePickerElementFlag+NSYearMonthDayDatePickerElementFlag)];
    templates = [templates arrayByAddingObject:template];
    
    keyPaths = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"fin"], nil];
    template = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:keyPaths rightExpressionAttributeType:NSDateAttributeType modifier:NSDirectPredicateModifier operators:operators options:nil];
    // PLANTE A LA COMPIL [[[template templateViews] objectAtIndex:2] setDatePickerElements:(NSHourMinuteDatePickerElementFlag+NSYearMonthDayDatePickerElementFlag)];
    templates = [templates arrayByAddingObject:template];
    
    for (template in templates) { if ([[template templateViews] count] == 3) { [[[template templateViews] objectAtIndex:2] setFrameSize:NSMakeSize(200, 20)]; } }
    
    [self.uiRegles setRowTemplates:templates];
  
}




-(void)sortMenu:(NSMenu*)menu {
    // Copied from web : http://stackoverflow.com/questions/7367438/sort-nsmenuitems-alphabetically-and-by-whether-they-have-submenus-or-not
    NSArray* items = [menu itemArray];
    [menu removeAllItems];
    NSSortDescriptor* alphaDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    items = [items sortedArrayUsingDescriptors:[NSArray arrayWithObjects:alphaDescriptor, nil]];

    for(NSMenuItem* item in items){
        [menu addItem:item];
        if(item.isHidden){
            item.hidden = false;
        }
    }
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Home.TV_Progs" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"Home.TV_Progs"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel {
//    if (_managedObjectModel) {
//        return _managedObjectModel;
//    }
//	
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TV_Progs" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return _managedObjectModel;
    return nil;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
//    if (_persistentStoreCoordinator) {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSManagedObjectModel *mom = [self managedObjectModel];
//    if (!mom) {
//        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
//        return nil;
//    }
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
//    NSError *error = nil;
//    
//    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
//    
//    if (!properties) {
//        BOOL ok = NO;
//        if ([error code] == NSFileReadNoSuchFileError) {
//            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
//        }
//        if (!ok) {
//            [[NSApplication sharedApplication] presentError:error];
//            return nil;
//        }
//    } else {
//        if (![properties[NSURLIsDirectoryKey] boolValue]) {
//            // Customize and localize this error.
//            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
//            
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
//            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
//            
//            [[NSApplication sharedApplication] presentError:error];
//            return nil;
//        }
//    }
//    
//    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"TV_Progs.storedata"];
//    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
//    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
//        [[NSApplication sharedApplication] presentError:error];
//        return nil;
//    }
//    _persistentStoreCoordinator = coordinator;
//    
//    return _persistentStoreCoordinator;
    return nil;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext {
//    if (_managedObjectContext) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (!coordinator) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
//        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
//        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        [[NSApplication sharedApplication] presentError:error];
//        return nil;
//    }
//    _managedObjectContext = [[NSManagedObjectContext alloc] init];
//    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//
//    return _managedObjectContext;
    return nil;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window{
//    return [[self managedObjectContext] undoManager];
    return nil;
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Lire le fichier xml
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)changeCatalogue:(id)sender {

    // Lecture des données du fichier XML de programmes
    if ([[self uiCatalogSource] indexOfSelectedItem] == 0)
    { [self parseFichier:[homeFile stringByAppendingString:@"tnt.xml"]]; }
    else
    { [self parseFichier:[homeFile stringByAppendingString:@"complet.xml"]]; }

    // Raffraichier les structures de données
    [self importer:sender];
}

- (IBAction)importer:(id)sender {

    NSDate * maintenant = [NSDate date];
    NSDate * First;
    NSDate * Last;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSUInteger NbLignes;

    [self.uiProgressAnalyse setHidden:NO];
    [self.uiProgressAnalyse startAnimation:sender];

    // Initialisation des variables
    NSDate * stat = [NSDate date];
    [allProgs removeAllObjects];

    //Récupération des chaines
    [self.uiCatalogChaines setIntValue:(int)[[myParser chaines] count]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[homeFile stringByAppendingString:@"TvProgs.MesChaines"]]) { allChaines = [NSKeyedUnarchiver unarchiveObjectWithFile:[homeFile stringByAppendingString:@"TvProgs.MesChaines"]]; }
    
    // Sanity check sur les chaines
    for (int i = 0; i < [[myParser chaines] count]; i++) {
        if ( [[[[myParser chaines]objectAtIndex:i] idchaine] isNotEqualTo:[allChaines[[[[[myParser chaines] objectAtIndex:i] idchaine] intValue]] idchaine]] ) {
            // On l'ajoute à notre liste
            allChaines[[[[[myParser chaines] objectAtIndex:i] idchaine] intValue]] = [myParser chaines][i];
            [self loggue:[NSString stringWithFormat:@"Nouvelle chaine : %@\n", [[[myParser chaines] objectAtIndex:i] nom]]];
        }
    }
    
    // Fabrication de la liste des chaines à afficher
    [mesChaines removeAllObjects];
    for (int i = 0; i < [allChaines count]; i++) {
        if ( [[[allChaines objectAtIndex:i] idchaine] isNotEqualTo:NULL] ) { [mesChaines addObject:[allChaines objectAtIndex:i]]; }
    }
        
    [self loggue:[NSString stringWithFormat:@"Chaines chargées [%.2f sec]\n", [[NSDate date] timeIntervalSinceDate:stat]]];
    stat = [NSDate date];
    
   // Récupération des programmes
    First = [(Prog *)[myParser programmes][0] debut];
    Last = [(Prog *)[myParser programmes][0] fin];
    NbLignes = [[myParser programmes] count];
    [self.uiCatalogProgs setIntValue:(int)NbLignes];
    for(int i = 0; i < NbLignes; i++) {
        if ( [[(Prog *)[myParser programmes][i] debut] compare:First] == NSOrderedAscending ) { First = [(Prog *)[myParser programmes][i] debut]; }
        if ( [[(Prog *)[myParser programmes][i] fin] compare:Last] == NSOrderedDescending ) { Last = [(Prog *)[myParser programmes][i] fin]; }
        
        if ( ( [[(Prog *)[myParser programmes][i] fin] compare:maintenant] == NSOrderedDescending ) && ([[allChaines[[[[myParser programmes][i] chaine] intValue]] mesChaines] isEqualTo:[NSNumber numberWithInt:NSOnState]]) ) {
            Prog *new = [[Prog alloc] init];
            new = (Prog *)[myParser programmes][i];
            [allProgs addObject:new];
        }
	}
    progs = [NSArray arrayWithArray:allProgs];
    
    [self loggue:[NSString stringWithFormat:@"Programmes purgés [%.2f sec]\n", [[NSDate date] timeIntervalSinceDate:stat]]];
    stat = [NSDate date];
    
    // Initialisation des compteurs de l'écran
    [formatter setDateFormat:@"EEE, dd MMM à hh:mm"];
    [self.uiCatalogueDebut setStringValue:[formatter stringFromDate:First]];
    [self.uiCatalogFin setStringValue:[formatter stringFromDate:Last]];
    [self.uiNbChaines setIntValue:(int)[mesChaines count]];
    [self.uiNbProgs setIntValue:(int)[allProgs count] ];
 
    // Initialisation des listes déroulantes
    [self.uiCategories removeAllItems];
    [self.uiCategories addItemWithTitle:@"All"];
    for(int i = 0; i < [allProgs count]; i++) {	[self.uiCategories addItemWithTitle:[allProgs[i] Categorie]]; }
    [self sortMenu:[self.uiCategories menu]];
    [self changeCategorie:self.uiCategories];
    
    [self.uiProgressAnalyse stopAnimation:sender];
    [self.uiProgressAnalyse setHidden:YES];
    
    // Initialisation du tableau
    [self.uiTableau reloadData];
    [self.uiTabChaines reloadData];
}

- (void)parseFichier:(NSString *)fichier {
    
    NSDate * stat = [NSDate date];

    myParser = [[XMLToObjectParser alloc] parseXMLfromFile:[NSInputStream inputStreamWithFileAtPath:fichier] parseError:nil];
    
    [self loggue:[NSString stringWithFormat:@"Fichier chargé [%.2f sec]\n", [[NSDate date] timeIntervalSinceDate:stat]]];
}

- (IBAction)downloadFile:(id)sender {
    
    // Sources alternatives :
    // http://kevinpato.free.fr/xmltv/download/complet.zip
    // http://kevinpato.free.fr/xmltv/download/tnt.zip
    // http://xmltv.dyndns.org/download/complet.zip
    // http://xmltv.dyndns.org/download/tnt.zip
 
    NSDate * stat = [NSDate date];
    NSString * fichier;
    NSString * source;
    
    [self.uiProgressLoad setHidden:NO];
    [self.uiProgressLoad startAnimation:sender];
    
    // Détermination des fichiers
    if ([[self uiCatalogSource] indexOfSelectedItem] == 0){
        // Download du fichier TNT
        fichier = @"/tmp/tnt.zip";
        source = @"http://xmltv.dyndns.org/download/tnt.zip";
    }
    else {
        // Download du fichier complet
        fichier = @"/tmp/complet.zip";
        source = @"http://xmltv.dyndns.org/download/complet.zip";
    }

    // Downloading
    [self loadOnWeb:source Vers:fichier];
    [self loggue:[NSString stringWithFormat:@"Fichier downloadé [%.2f sec]\n", [[NSDate date] timeIntervalSinceDate:stat]]];
    stat = [NSDate date];
    
    // Unzipping
    [self unzipFile:fichier];
    [self loggue:[NSString stringWithFormat:@"Fichier décompressé [%.2f sec]\n", [[NSDate date] timeIntervalSinceDate:stat]]];
    
    [self.uiProgressLoad stopAnimation:sender];
    [self.uiProgressLoad setHidden:YES];

    
    [self changeCatalogue:sender];
}

- (void) loadOnWeb:(NSString *)source Vers:(NSString *)fichier {
    NSData *urlData;
    urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:source]];
    if ( urlData ) { [urlData writeToFile:fichier atomically:YES]; }    
}

- (void) unzipFile:(NSString *)fichier {
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setLaunchPath:@"/usr/bin/unzip"];
    [unzipTask setCurrentDirectoryPath:homeFile];
    [unzipTask setArguments:[NSArray arrayWithObjects:@"-q", @"-o", fichier, nil]];
    [unzipTask launch];
    [unzipTask waitUntilExit];    
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Geston dynamique des categories2 (sur modif de categorie1)
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)changeCategorie:(id)sender {
    
    // Récupération de la catégorie1
    NSString *categ1 = [(NSPopUpButton *)sender titleOfSelectedItem];
    
    // Initialisation des listes déroulantes
    [self.uiSousCategories removeAllItems];
    [self.uiSousCategories addItemWithTitle:@"All"];
    for(int i = 0; i < [allProgs count]; i++) {
        if (([[allProgs[i] Categorie] isEqualToString:categ1]) || ([categ1 isEqualToString:@"All"]) )
            { [self.uiSousCategories addItemWithTitle:[allProgs[i] SousCategorie]]; }
    }
    [self sortMenu:[self.uiSousCategories menu]];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Afichage des éléments de la liste
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
        
    if ([[aTableColumn identifier] isEqualToString:@"tabDebut"]) { return [progs[rowIndex] debut]; }
    else if ([[aTableColumn identifier] isEqualToString:@"tabFin"]) { return [progs[rowIndex] fin]; }
    else if ([[aTableColumn identifier] isEqualToString:@"tabTitre"]) { return [progs[rowIndex] Titre]; }
    else if ([[aTableColumn identifier] isEqualToString:@"tabCategorie"]) { return [progs[rowIndex] Categorie]; }
    else if ([[aTableColumn identifier] isEqualToString:@"tabSousCategorie"]) { return [progs[rowIndex] SousCategorie]; }
    else if ([[aTableColumn identifier] isEqualToString:@"tabChaine"]) { return [allChaines[[[progs[rowIndex] chaine] intValue]] nom]; }

    // Tableau des filtres
    else if ([[aTableColumn identifier] isEqualToString:@"tabNomFiltre"]) { return [mesFiltres[rowIndex] NomFiltre]; }
    else if ([[aTableColumn identifier] isEqualToString:@"tabNbProgsFiltre"]){ return [[NSNumber alloc] initWithInteger:[self appliquerPredicat:[NSPredicate predicateWithFormat:[mesFiltres[rowIndex] Predicat]] pourDeVrai:FALSE]]; }

    // Tableau des chaines
    else if ([[aTableColumn identifier] isEqualToString:@"chaineCoche"]) { return [mesChaines[rowIndex] mesChaines]; }
    else if ([[aTableColumn identifier] isEqualToString:@"chaineLogo"]) { return [[NSImage alloc] initWithContentsOfFile:[[mesChaines[rowIndex] icone] stringByReplacingOccurrencesOfString:@"http://localhost" withString:[homeApp stringByAppendingString:@"logos/"] ]]; }
    else if ([[aTableColumn identifier] isEqualToString:@"chaineNumero"]) { return [mesChaines[rowIndex] nom]; }
    
    else { NSLog(@"Erreur objectValueForTableColumn : colomn %@ not found", [aTableColumn identifier]); return @"";}
}

- (void)tableView:(NSTableView*)aTableView setObjectValue:(id)val forTableColumn:(NSTableColumn*)aTableColumn row:(NSInteger)rowIndex {
    
    if([[aTableColumn identifier] isEqualToString:@"chaineCoche"]) {
        if ( [val boolValue] )
            {
                [mesChaines[rowIndex] setValue:[NSNumber numberWithInt:NSOnState] forKey:@"mesChaines"];
                [allChaines[[[mesChaines[rowIndex] idchaine] intValue]] setValue:[NSNumber numberWithInt:NSOnState] forKey:@"mesChaines"];
            }
        else
            {
                [mesChaines[rowIndex] setValue:[NSNumber numberWithInt:NSOffState] forKey:@"mesChaines"];
                [allChaines[[[mesChaines[rowIndex] idchaine] intValue]] setValue:[NSNumber numberWithInt:NSOffState] forKey:@"mesChaines"];
            }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (aTableView == [self uiTabChaines] ) { return [mesChaines count]; }
    if (aTableView == [self uiTableau] ) { return [progs count]; }
    if (aTableView == [self uiFiltres] ) { return [mesFiltres count]; }
    else { NSLog(@"Erreur numberOfRowsInTableView"); return 0;}
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange: (NSArray *)oldDescriptors {
    NSArray *newDescriptors = [tableView sortDescriptors];
    progs = [progs sortedArrayUsingDescriptors:newDescriptors];
    [tableView reloadData];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {

    [aTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:FALSE];
    [self rowSelected:aTableView];
    return YES;
}
                                                


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Gestion de mes chaines
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)validerChaines:(id)sender {
    [NSKeyedArchiver archiveRootObject:allChaines toFile:[homeFile stringByAppendingString:@"TvProgs.MesChaines"]];
    [self.ecranChaines close];
    
    [self importer:sender];
}

- (IBAction)annulerChaines:(id)sender {
    [self importer:sender];
    
    [self.ecranChaines close];
}

- (IBAction)afficheChaines:(id)sender {
    [self.ecranChaines makeKeyAndOrderFront:sender];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Afichage des détails du programme suite à sélection dans la liste
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)rowSelected:(id)sender {

    NSInteger ligne = [(NSTableView *)sender selectedRow];
    if ( ligne == -1 ) { return; }
  
    if (sender == [self uiTableau]) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        // Nettoyage de l'écran
        [self.uiTitre setStringValue:@""];
        [self.uiSoustitre setStringValue:@""];
        [self.uiDate setStringValue:@""];
        [self.uiDebut setStringValue:@""];
        [self.uiFin setStringValue:@""];
        [self.uiDescription setStringValue:@""];
        [self.uiAnnee setStringValue:@""];
        [self.uiChaine setImage:mire];
        [self.uiCSA10 setHidden:TRUE];
        [self.uiCSA12 setHidden:TRUE];
        [self.uiCSA16 setHidden:TRUE];
        [self.uiCSA18 setHidden:TRUE];
        [self.uiCSAP setHidden:TRUE];
        [self.uiHD setHidden:TRUE];
        [self.uiLQ setHidden:TRUE];
        [self.uiDolby setHidden:TRUE];
        [self.uiSurround setHidden:TRUE];
        [self.uiStar1 setHidden:TRUE];
        [self.uiStar2 setHidden:TRUE];
        [self.uiStar3 setHidden:TRUE];
        [self.uiStar4 setHidden:TRUE];
        [self.uiStar5 setHidden:TRUE];
        [self.ui169 setHidden:TRUE];
        [self.ui43 setHidden:TRUE];
        [self.uiImage setImage:mire];
        [self.uiCasting setStringValue:@"Toto"];
      
        // Non géré : episode
        
        // Affichage des logos
        if ([[progs[ligne] Rating] isEqualToString:@"-10"]) { [self.uiCSA10 setHidden:FALSE]; }
        else if ([[progs[ligne] Rating] isEqualToString:@"-12"]) { [self.uiCSA12 setHidden:FALSE]; }
        else if ([[progs[ligne] Rating] isEqualToString:@"-16"]) { [self.uiCSA16 setHidden:FALSE]; }
        else if ([[progs[ligne] Rating] isEqualToString:@"-18"]) { [self.uiCSA18 setHidden:FALSE]; }
        else if ([[progs[ligne] Rating] isEqualToString:@"Tout public"]) { [self.uiCSAP setHidden:FALSE]; }
        if ([[progs[ligne] Qualite] isEqualToString:@"HDTV"]) { [self.uiHD setHidden:FALSE]; } else {[self.uiLQ setHidden:FALSE];}
        if ([[progs[ligne] Aspect] isEqualToString:@"16:9"]) { [self.ui169 setHidden:FALSE]; }
        if ([[progs[ligne] Aspect] isEqualToString:@"4:3"]) { [self.ui43 setHidden:FALSE]; }
        if ([[progs[ligne] Audio] isEqualToString:@"dolby"]) { [self.uiDolby setHidden:FALSE]; }
        if ([[progs[ligne] Audio] isEqualToString:@"surround"]) { [self.uiSurround setHidden:FALSE]; }
        
        // Affichage des étoiles
        if ([[progs[ligne] Note] isEqualTo:@"5/5"]) { [self.uiStar1 setHidden:FALSE]; [self.uiStar2 setHidden:FALSE]; [self.uiStar3 setHidden:FALSE]; [self.uiStar4 setHidden:FALSE]; [self.uiStar5 setHidden:FALSE]; }
        else if ([[progs[ligne] Note] isEqualTo:@"4/5"]) { [self.uiStar1 setHidden:FALSE]; [self.uiStar2 setHidden:FALSE]; [self.uiStar3 setHidden:FALSE]; [self.uiStar4 setHidden:FALSE]; }
        else if ([[progs[ligne] Note] isEqualTo:@"3/5"]) { [self.uiStar1 setHidden:FALSE]; [self.uiStar2 setHidden:FALSE]; [self.uiStar3 setHidden:FALSE]; }
        else if ([[progs[ligne] Note] isEqualTo:@"2/5"]) { [self.uiStar1 setHidden:FALSE]; [self.uiStar2 setHidden:FALSE]; }
        else if ([[progs[ligne] Note] isEqualTo:@"1/5"]) { [self.uiStar1 setHidden:FALSE]; }
        
        // Affichage du titre, sous titre, description et showview
        [self.uiTitre setStringValue:[progs[ligne] Titre] ];
        if ([progs[ligne] SousTitre] != nil) { [self.uiSoustitre setStringValue:[progs[ligne] SousTitre] ]; }
        if ([progs[ligne] Resume] != nil) { [self.uiDescription setStringValue:[progs[ligne] Resume] ]; }
        if ([progs[ligne] Annee] != 0) { [self.uiAnnee setIntegerValue:[progs[ligne] Annee] ]; }
        
        // Affichage du casting
        NSMutableArray * casting = [progs[ligne] cast];
        NSString * credits = @"";
        for(int i = 0; i < [casting count]; i++) {
            credits = [credits stringByAppendingString:[(Casting *)casting[i] role]];
            credits = [credits stringByAppendingString:@" : "];
            credits = [credits stringByAppendingString:[(Casting *)casting[i] nom]];
            credits = [credits stringByAppendingString:@"\n"];
        }
        if (credits != nil) {[self.uiCasting setStringValue:credits];}
        
        // Affichage des horaires
        [formatter setDateFormat:@"EEEE, dd MMM"];
        [self.uiDate setStringValue:[formatter stringFromDate:[progs[ligne] debut]]];
        [formatter setDateFormat:@"HH:mm"];
        [self.uiDebut setStringValue:[formatter stringFromDate:[progs[ligne] debut]]];
        [formatter setDateFormat:@"HH:mm"];
        [self.uiFin setStringValue:[formatter stringFromDate:[progs[ligne] fin]]];
        
        // Affichage de l'icone de la chaine
        NSString *icone = [allChaines[[[progs[ligne] chaine] intValue]] icone];
        [self.uiChaine setImage:[[NSImage alloc] initWithContentsOfFile:[icone stringByReplacingOccurrencesOfString:@"http://localhost" withString:[homeApp stringByAppendingString:@"logos/"] ]]];

        // Affichage de l'image du programme
        [self.uiImage setImage:[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[progs[ligne] icone]]]];
    }
    
    else if (sender == [self uiFiltres]) {
        NSDate * stat = [NSDate date];
        [self.uiRegles setObjectValue:[NSPredicate predicateWithFormat:[mesFiltres[ligne] Predicat]]];
        [self appliquerPredicat:[NSPredicate predicateWithFormat:[mesFiltres[ligne] Predicat]] pourDeVrai:TRUE];
        [self.uiTableau reloadData];
        [self loggue:[NSString stringWithFormat:@"Filtre appliqué : %lu programmes [%.2f sec]\n", [progs count], [[NSDate date] timeIntervalSinceDate:stat]]];
    }
    
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Méthodes associées aux bouton de filtre (Filtrer, Sauver, Défiltrer)
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)sauverFiltre:(id)sender {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Sauvegarde du filtre" defaultButton:@"Valider" alternateButton:@"Annuler" otherButton:nil informativeTextWithFormat:@"Merci de donner un nom au filtre"];
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
        [alert setAccessoryView:input];
        
        NSInteger button = [alert runModal];
        if ((button == NSAlertDefaultReturn) && ( [[input stringValue] isNotEqualTo:@""]) ){
            NSDate * stat = [NSDate date];           
            Filtre * filtreCourant = [[Filtre alloc] init];
            filtreCourant.NomFiltre = [input stringValue];
            filtreCourant.Predicat = [[self.uiRegles predicate] predicateFormat];
            [mesFiltres addObject:filtreCourant];
            [NSKeyedArchiver archiveRootObject:mesFiltres toFile:[homeFile stringByAppendingString:@"TvProgs.Filtres"]];
            [self loggue:[NSString stringWithFormat:@"Filtre sauvegardé [%.2f sec]\n", [[NSDate date] timeIntervalSinceDate:stat]]];
            [self.uiFiltres reloadData];
        }
        else if (button == NSAlertAlternateReturn) { return; }
        else { [self sauverFiltre:sender]; }
    
}

- (IBAction)defiltrer:(id)sender {
    [self.uiCategories selectItemAtIndex:0];
    [self.uiSousCategories selectItemAtIndex:0];
    [self.uiQuand setState:NSOnState atRow:0 column:0];
    [self.uiHoraire setState:NSOnState atRow:0 column:0];
    [self.uiFmot setStringValue:@""];
    [self.uiFtitre setState:NSOnState];
    [self.uiFsoustitre setState:NSOnState];
    [self.uiFresume setState:NSOnState];
    
    [self.uiRegles setObjectValue:[NSPredicate predicateWithFormat:@"(Titre contains '' AND Titre contains '')"]];
    
    progs = [NSArray arrayWithArray:allProgs];
    [self.uiTableau reloadData];
   
}

- (IBAction)filtrePredicate:(id)sender {
    
    // http://funwithobjc.tumblr.com/post/1677163679/creating-an-advanced-nspredicateeditorrowtemplate
    // http://funwithobjc.tumblr.com/post/1646098126/creating-a-simple-nspredicateeditorrowtemplate
    // http://www.peterfriese.de/using-nspredicate-to-filter-data/
    
    NSPredicate * predicatetoApply;
    NSDate * stat = [NSDate date];
    
    // On copie le prédicat sur l'autre onglet
    if ([[self.uiTabul selectedTabViewItem] isEqualTo:[self.uiTabul tabViewItemAtIndex:0] ]) { predicatetoApply = [self click2predicate:sender]; [self.uiRegles setObjectValue:predicatetoApply];}
    else { predicatetoApply = [self.uiRegles predicate]; [self predicate2click:predicatetoApply]; }
    
    [self appliquerPredicat:predicatetoApply pourDeVrai:TRUE];
    [self loggue:[NSString stringWithFormat:@"Prédicat appliqué : %lu programmes [%.2f sec]\n", [progs count], [[NSDate date] timeIntervalSinceDate:stat]]];
    
    // Raffraichissement du tableau
    [self.uiTableau reloadData];
}

- (IBAction)supprimerPredicat:(id)sender {
    if ([[self uiFiltres] selectedRow] != -1) {
        [mesFiltres removeObjectAtIndex:[[self uiFiltres] selectedRow]];
        [NSKeyedArchiver archiveRootObject:mesFiltres toFile:[homeFile stringByAppendingString:@"TvProgs.Filtres"]];
        [[self uiFiltres] reloadData];
   }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Gestion du logger
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loggue:(NSString *)texte {
    
    [self.uiLogger insertText:texte];
    [self.uiLogger scrollToEndOfDocument:self];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Récupération ou application des predicats
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSPredicate *)click2predicate:(id)sender {
    NSString * texteDuPredicat = @"";
    int cont = 0;
    int lcont = 0;
    
    if (([[self.uiFmot stringValue] isNotEqualTo:@""]) && ([self.uiFtitre state]+[self.uiFsoustitre state]+[self.uiFresume state] != 0) ){
        texteDuPredicat = @"( ";
        
        if ( [self.uiFtitre state] == 1) { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@"Titre CONTAINS[cd] '%@'", [self.uiFmot stringValue] ]; lcont = 1; }
        if ( [self.uiFsoustitre state] == 1) {
            if (lcont == 1) { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@" OR SousTitre CONTAINS[cd] '%@'", [self.uiFmot stringValue] ]; }
            else { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@"SousTitre CONTAINS[cd] '%@'", [self.uiFmot stringValue] ]; lcont = 1; }
        }
        if ( [self.uiFresume state] == 1) {
            if (lcont == 1) { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@" OR Resume CONTAINS[cd] '%@'", [self.uiFmot stringValue] ]; }
            else { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@"Resume CONTAINS[cd] '%@'", [self.uiFmot stringValue] ]; }
        }
        
        texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@" ) "];
        cont = 1;
    }
    
    if ([[self.uiCategories titleOfSelectedItem] isNotEqualTo:@"All"]) {
        if (cont == 1) { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@" AND Categorie == '%@'", [self.uiCategories titleOfSelectedItem]]; }
        else { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@"Categorie == '%@'", [self.uiCategories titleOfSelectedItem]]; cont = 1; }
    }
    
    if ([[self.uiSousCategories titleOfSelectedItem] isNotEqualTo:@"All"]) {
        if (cont == 1) { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@" AND SousCategorie == '%@'", [self.uiSousCategories titleOfSelectedItem]]; }
        else { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@"SousCategorie == '%@'", [self.uiSousCategories titleOfSelectedItem]]; cont = 1; }
    }
    
    NSInteger ligneSelectionnee = [self.uiQuand selectedRow];
    if (ligneSelectionnee != 0) {
        NSString * debut;
        NSString * fin;
        
        if (ligneSelectionnee == 1) { debut = @"CAST(now(), 'NSNumber') - 900"; fin = @"CAST(now(), 'NSNumber') + 1800"; }
        if (ligneSelectionnee == 2) { debut = @"'today at 00:00'"; fin = @"'today at 23:59'"; }
        if (ligneSelectionnee == 3) { debut = @"'tomorrow at 00:00'"; fin = @"'tomorrow at 23:59'"; }
        if (ligneSelectionnee == 4) { debut = @"'today at 20:30'"; fin = @"'today at 21:01'"; }
        if (ligneSelectionnee == 5) { debut = @"'today at 22:15'"; fin = @"'today at 23:00'"; }
        if (ligneSelectionnee == 6) { debut = @"'tomorrow at 20:30'"; fin = @"'tomorrow at 21:01'"; }
        if (ligneSelectionnee == 7) { debut = @"'tomorrow at 22:15'"; fin = @"'tomorrow at 23:00'"; }
        if (cont == 1) { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@" AND ((debut >= CAST(%@,'NSDate') AND debut <= CAST(%@,'NSDate') ) OR debut <= CAST(1000,'NSDate'))", debut, fin ]; }
        else { texteDuPredicat = [texteDuPredicat stringByAppendingFormat:@"((debut >= CAST(%@,'NSDate') AND debut <= CAST(%@,'NSDate') ) OR debut <= CAST(1000,'NSDate'))", debut, fin]; }
    }
    
    return [NSPredicate predicateWithFormat:texteDuPredicat];
}

-(void)predicate2click:(NSPredicate *)predicate {
    // TODO ?
}

-(NSInteger)appliquerPredicat:(NSPredicate *)predicat pourDeVrai:(BOOL)vraiment {
    
    if (vraiment) {
        progs = [allProgs filteredArrayUsingPredicate:predicat];
        return [progs count];
    }
    else {
        return [[allProgs filteredArrayUsingPredicate:predicat] count];
        
    }
}





- (IBAction)f1:(id)sender {


    Prog * p;
    int i = 0;
    int j = 0;
    int k = 0;
    int l = 0;
    
    
    for (p in allProgs) {
        
        if ( ([[p fin] timeIntervalSinceDate:[p debut]]) < 600) { i = i + 1; }
        if ( ([[p fin] timeIntervalSinceDate:[p debut]]) < 300) { j = j + 1; }
        if ( [[p Categorie] isEqualToString:@"météo"]) {k = k + 1; }
    }
    NSLog(@"On a %u lignes de moins de 10 minutes", i);
    NSLog(@"On a %u lignes de moins de 5 minutes", j);
    NSLog(@"On a %u lignes de météo", k);
    NSLog(@"On a %u lignes de moins de 10 minutes", l);
}

- (IBAction)f2:(id)sender {
    
    Prog * p;
    NSMutableArray * toSave;
    
    NSLog(@"allProgs contient %lu enregistrements", [allProgs count]);
    
    toSave = [[NSMutableArray alloc] init];
    
    for (p in allProgs) {
        p.logo = [[allChaines[[p.chaine intValue]] icone] stringByReplacingOccurrencesOfString:@"http://localhost/" withString:@""];
        p.chaine = [allChaines[[p.chaine intValue]] nom];
        //if ( ([[p fin] timeIntervalSinceDate:[p debut]]) < 300) { NSLog(@"Moins de 5 minutes : %@ sur %@ (%@)", p.Titre, p.chaine, p.Categorie ); }
        
        if ( [p.Resume rangeOfString:@"--  Critique : "].location != NSNotFound ) {
            NSArray * tab = [p.Resume componentsSeparatedByString:@"--  Critique : "];
            p.Resume = [tab objectAtIndex:0];
            p.critique = [tab objectAtIndex:1];
        }
        else { p.critique = @""; }

        if ( !([p.Categorie isEqualToString:@"météo"]) && !([p.Categorie isEqualToString:@"fin"]) && !([p.SousCategorie isEqualToString:@"programme indéterminé"])) { [toSave addObject:p]; }
    }
    NSLog(@"On va sauvegarder %lu enregistrements", [toSave count]);
   
    [NSKeyedArchiver archiveRootObject:[toSave sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"debut" ascending:YES], nil]] toFile:@"/tmp/TvProgs.Progs"];

    
}

- (IBAction)f3:(id)sender {
    NSDate * stat = [NSDate date];
    
    allProgs = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/tmp/TvProgs.Progs"];
    
    [self loggue:[NSString stringWithFormat:@"NSKeyedUnarchiver : %lu programmes [%.2f sec]\n", [allProgs count], [[NSDate date] timeIntervalSinceDate:stat]]];
    
}







@end
