//
//  XMLToObjectParser.m
//  TV Progs
//
//  Created by Cyril Delamare on 10/11/12.
//  Copyright (c) 2012 Cd. All rights reserved.
//

#import "XMLToObjectParser.h"
#import "Prog.h"
#import "Chaine.h"




@implementation XMLToObjectParser


- (NSArray *)programmes
{
	return programmes;
}
- (NSArray *)chaines
{
	return chaines;
}

- (id)parseXMLfromFile:(NSInputStream *)file
            parseError:(NSError **)error
{
	programmes = [[NSMutableArray alloc] init];
	chaines = [[NSMutableArray alloc] init];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss ZZZZZ"];
    
	NSXMLParser *parser = [[NSXMLParser alloc] initWithStream:file];
	[parser setDelegate:self];
	[parser parse];
   
	if([parser parserError] && error) {
		*error = [parser parserError];
	}
    
	return self;
}


- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"programme"]) {
		// create an instance of a class on run-time
		item = [[Prog alloc] init];
        [item setValue:@"" forKey:@"Resume"];
        [item setValue:@"" forKey:@"Titre"];
        [item setValue:@"" forKey:@"SousTitre"];
        [item setValue:@"" forKey:@"icone"];
        [item setValue:@"?" forKey:@"Note"];
        [item setValue:@"?" forKey:@"Rating"];
        [item setValue:@"?" forKey:@"Aspect"];
        [item setValue:@"LQ" forKey:@"Qualite"];
        [item setValue:@"?" forKey:@"Audio"];
        [item setValue:@"?" forKey:@"Inedit"];
        [item setValue:@2013 forKey:@"Annee"];
        [item setValue:[[NSMutableArray alloc] init] forKey:@"cast"];
        [item setValue:[dateFormatter dateFromString:[attributeDict objectForKey:@"start"]] forKey:@"debut"];
        [item setValue:[dateFormatter dateFromString:[attributeDict objectForKey:@"stop"]] forKey:@"fin"];
        [item setValue:[[attributeDict objectForKey:@"channel"] substringFromIndex:1] forKey:@"chaine"];
        trieur = 0;
	}
	else if([elementName isEqualToString:@"channel"]) {
        // create an instance of a class on run-time
		item = [[Chaine alloc] init];
        [item setValue:@"" forKey:@"icone"];
        [item setValue:[[attributeDict objectForKey:@"id"] substringFromIndex:1] forKey:@"idchaine"];
        [item setValue:[NSNumber numberWithInt:NSOnState] forKey:@"mesChaines"];
	}
    else if([elementName isEqualToString:@"icon"]) { if ([[item valueForKey:@"icone"] isEqualTo:@""]) { [item setValue:[attributeDict objectForKey:@"src"] forKey:@"icone"];} }
	else {
		currentNodeName = [elementName copy];
		currentNodeContent = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"programme"])              { [programmes addObject:item]; item = nil; }
    else if([elementName isEqualToString:@"channel"])           { [chaines addObject:item]; item = nil; }
    else if([elementName isEqualToString:@"display-name"])      { [item setValue:currentNodeContent forKey:@"nom"]; }
    else if([elementName isEqualToString:@"desc"])              { [item setValue:currentNodeContent forKey:@"Resume"]; }
    else if([elementName isEqualToString:@"title"])             { [item setValue:currentNodeContent forKey:@"Titre"]; }
    else if([elementName isEqualToString:@"date"])              { [item setValue:currentNodeContent forKey:@"Annee"]; }
    else if([elementName isEqualToString:@"sub-title"])         { [item setValue:currentNodeContent forKey:@"SousTitre"]; }
    else if([elementName isEqualToString:@"episode-num"])       { [item setValue:currentNodeContent forKey:@"episode"]; }
    else if([elementName isEqualToString:@"stereo"])            { [item setValue:currentNodeContent forKey:@"Audio"]; }
    else if([elementName isEqualToString:@"aspect"])            { [item setValue:currentNodeContent forKey:@"Aspect"]; }
    else if([elementName isEqualToString:@"quality"])           { [item setValue:currentNodeContent forKey:@"Qualite"]; }
    else if([elementName isEqualToString:@"previously-shown"])  { [item setValue:@"rediffusion" forKey:@"Inedit"]; }
    else if([elementName isEqualToString:@"premiere"])          { [item setValue:@"inedit" forKey:@"Inedit"]; }
    else if([elementName isEqualToString:@"rating"])            { [item setValue:sauveValue forKey:@"Rating"]; }
    else if([elementName isEqualToString:@"star-rating"])       { [item setValue:sauveValue forKey:@"Note"]; }
    else if([elementName isEqualToString:@"category"]) {
        if (trieur == 0)    { [item setValue:currentNodeContent forKey:@"Categorie"]; trieur = 1; }
        else                { [item setValue:currentNodeContent forKey:@"SousCategorie"]; }
    }
    else if([elementName isEqualToString:@"value"])     { sauveValue = currentNodeContent; }
    else if([elementName isEqualToString:@"actor"])     { Casting *new = [[Casting alloc] init]; [new setValue:@"Acteur" forKey:@"role"]; [new setValue:currentNodeContent forKey:@"nom"]; [[(Prog *)item cast] addObject:new]; }
    else if([elementName isEqualToString:@"director"])  { Casting *new = [[Casting alloc] init]; [new setValue:@"Réalisateur" forKey:@"role"]; [new setValue:currentNodeContent forKey:@"nom"]; [[(Prog *)item cast] addObject:new]; }
    else if([elementName isEqualToString:@"writer"])    { Casting *new = [[Casting alloc] init]; [new setValue:@"Auteur" forKey:@"role"]; [new setValue:currentNodeContent forKey:@"nom"]; [[(Prog *)item cast] addObject:new]; }
    else if([elementName isEqualToString:@"guest"])     { Casting *new = [[Casting alloc] init]; [new setValue:@"Invité" forKey:@"role"]; [new setValue:currentNodeContent forKey:@"nom"]; [[(Prog *)item cast] addObject:new]; }
    else if([elementName isEqualToString:@"composer"])  { Casting *new = [[Casting alloc] init]; [new setValue:@"Compositeur" forKey:@"role"]; [new setValue:currentNodeContent forKey:@"nom"]; [[(Prog *)item cast] addObject:new]; }
    else if([elementName isEqualToString:@"presenter"]) { Casting *new = [[Casting alloc] init]; [new setValue:@"Présentateur" forKey:@"role"]; [new setValue:currentNodeContent forKey:@"nom"]; [[(Prog *)item cast] addObject:new]; }
    else if([elementName isEqualToString:@"audio"])     { }         // l'info est dans la balise <stereo>
    else if([elementName isEqualToString:@"video"])     { }         // l'info est dans les balises <qualite> et <aspect>
    else if([elementName isEqualToString:@"credits"])   { }         // l'info est dans les balises <director>, <actor>, <presenter>, <writer>, <guest> et <composer>
    else if([elementName isEqualToString:@"subtitles"]) { }         // l'info est dans la balise <language>
    else if([elementName isEqualToString:@"language"])  { }         // l'info est toujours "fr"
    else if([elementName isEqualToString:@"icon"])      { }         // Done
    else { NSLog(@"Not managed %@ : %@", elementName, currentNodeContent); }
    
    currentNodeContent = nil;
    currentNodeName = nil;
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
	[currentNodeContent appendString:string];
}

- (void)dealloc
{
	//[items release];
	//[super dealloc];
}

@end
