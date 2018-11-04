//
//  MyRowTemplate.m
//  TV Progs
//
//  Created by Cyril Delamare on 28/04/13.
//  Copyright (c) 2013 Cd. All rights reserved.
//

#import "MyRowTemplate.h"

@implementation MyRowTemplate


- (double) matchForPredicate:(NSPredicate *)predicate {
    
    if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
        if ([(NSCompoundPredicate *)predicate compoundPredicateType] == NSOrPredicateType) {
            
            NSCompoundPredicate * compound = (NSCompoundPredicate *)predicate;
            NSPredicate * souspredicat = [[compound subpredicates] objectAtIndex:1];
            
            if ([souspredicat isKindOfClass:[NSComparisonPredicate class]]) {
                if ([(NSComparisonPredicate *)souspredicat predicateOperatorType] == NSLessThanOrEqualToPredicateOperatorType) { return DBL_MAX; }
            }
        }
    }
    
    return 0.0;

}

- (NSPredicate *) predicateWithSubpredicates:(NSArray *)subpredicates {

    NSPredicate * p = [super predicateWithSubpredicates:subpredicates];
    
    if ([p isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate * comparison = (NSComparisonPredicate *)p;
        NSPredicate * compdeb = (NSComparisonPredicate *)p;
        NSPredicate * compfin = (NSComparisonPredicate *)p;
        NSExpression * right = [comparison rightExpression];
        NSString * debut;
        NSString * fin;
        NSExpression * castDeb;
        NSExpression * castFin;
        NSExpression * castNull;
        
        if ([[right constantValue] isEqual: @"Maintenant"]) {
            
            // Récupération de l'heure courante
            NSExpression * castNow = [NSExpression expressionForFunction:@"castObject:toType:"
                                                               arguments:[NSArray arrayWithObjects:[NSExpression expressionForFunction:@"now" arguments:[NSArray array]], [NSExpression expressionForConstantValue:@"NSNumber"], nil]];
            NSExpression * relativeTimestamp;

            // Il y a 15 minutes
            relativeTimestamp = [NSExpression expressionForFunction:@"from:subtract:" arguments:[NSArray arrayWithObjects:castNow, [NSExpression expressionForConstantValue:@900], nil]];
            castDeb = [NSExpression expressionForFunction:@"castObject:toType:" arguments:[NSArray arrayWithObjects:relativeTimestamp, [NSExpression expressionForConstantValue:@"NSDate"], nil]];
          
            // Dans 30 minutes
            relativeTimestamp = [NSExpression expressionForFunction:@"add:to:" arguments:[NSArray arrayWithObjects:castNow, [NSExpression expressionForConstantValue:@1800], nil]];
            castFin = [NSExpression expressionForFunction:@"castObject:toType:" arguments:[NSArray arrayWithObjects:relativeTimestamp, [NSExpression expressionForConstantValue:@"NSDate"], nil]];
        }
        else {
            if ([[right constantValue] isEqual: @"Aujourd'hui"]) { debut = @"today at 00:00"; fin = @"today at 23:59"; }
            if ([[right constantValue] isEqual: @"Demain"]) { debut = @"tomorrow at 00:00"; fin = @"tomorrow at 23:59"; }
            if ([[right constantValue] isEqual: @"Ce soir"]) { debut = @"today at 20:30"; fin = @"today at 21:01"; }
            if ([[right constantValue] isEqual: @"Ce soir (2ème partie)"]) { debut = @"today at 22:15"; fin = @"today at 23:00"; }
            if ([[right constantValue] isEqual: @"Demain soir"]) { debut = @"tomorrow at 20:30"; fin = @"tomorrow at 21:01"; }
            if ([[right constantValue] isEqual: @"Demain soir (2ème partie)"]) { debut = @"tomorrow at 22:15"; fin = @"tomorrow at 23:00"; }
            
            castDeb = [NSExpression expressionForFunction:@"castObject:toType:" arguments:[NSArray arrayWithObjects:[NSExpression expressionForConstantValue:debut], [NSExpression expressionForConstantValue:@"NSDate"], nil]];
            castFin = [NSExpression expressionForFunction:@"castObject:toType:" arguments:[NSArray arrayWithObjects:[NSExpression expressionForConstantValue:fin], [NSExpression expressionForConstantValue:@"NSDate"], nil]];
        }
        castNull = [NSExpression expressionForFunction:@"castObject:toType:" arguments:[NSArray arrayWithObjects:[NSExpression expressionForConstantValue:@"2010-10-10"], [NSExpression expressionForConstantValue:@"NSDate"], nil]];
        compdeb = [NSComparisonPredicate predicateWithLeftExpression:[comparison leftExpression] rightExpression:castDeb modifier:0 type:NSGreaterThanOrEqualToPredicateOperatorType options:0];
        compfin = [NSComparisonPredicate predicateWithLeftExpression:[comparison leftExpression] rightExpression:castFin modifier:0 type:NSLessThanOrEqualToPredicateOperatorType options:0];
        p = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:compdeb, compfin, nil]],
                                                                                        [NSComparisonPredicate predicateWithLeftExpression:[comparison leftExpression] rightExpression:castNull modifier:0 type:NSLessThanOrEqualToPredicateOperatorType options:0], nil]];
    }
    return p;
}

- (void) setPredicate:(NSPredicate *)predicate {
 
    NSComparisonPredicate * comparison = (NSComparisonPredicate *)[[(NSCompoundPredicate *)[[(NSCompoundPredicate *)predicate subpredicates] objectAtIndex:0] subpredicates] objectAtIndex:0];
  
    if ([[comparison rightExpression] expressionType] == 4) {
        predicate = [NSComparisonPredicate predicateWithLeftExpression:[comparison leftExpression]
                                                       rightExpression:[NSExpression expressionForConstantValue:@"Maintenant"]
                                                              modifier:[comparison comparisonPredicateModifier]
                                                                  type:NSMatchesPredicateOperatorType
                                                               options:[comparison options]];
    }
    else{
        NSString * label = nil;

        if ([[[comparison rightExpression] constantValue] isEqualTo:[NSDate dateWithNaturalLanguageString:@"today at 00:00"]]) { label = @"Aujourd'hui"; }
        if ([[[comparison rightExpression] constantValue] isEqualTo:[NSDate dateWithNaturalLanguageString:@"tomorrow at 00:00"]]) { label = @"Demain"; }
        if ([[[comparison rightExpression] constantValue] isEqualTo:[NSDate dateWithNaturalLanguageString:@"today at 20:30"]]) { label = @"Ce soir"; }
        if ([[[comparison rightExpression] constantValue] isEqualTo:[NSDate dateWithNaturalLanguageString:@"tomorrow at 20:30"]]) { label = @"Demain soir"; }
        if ([[[comparison rightExpression] constantValue] isEqualTo:[NSDate dateWithNaturalLanguageString:@"today at 22:15"]]) { label = @"Ce soir (2ème partie)"; }
        if ([[[comparison rightExpression] constantValue] isEqualTo:[NSDate dateWithNaturalLanguageString:@"tomorrow at 22:15"]]) { label = @"Demain soir (2ème partie)"; }
        
        predicate = [NSComparisonPredicate predicateWithLeftExpression:[comparison leftExpression] rightExpression:[NSExpression expressionForConstantValue:label] modifier:[comparison comparisonPredicateModifier] type:NSMatchesPredicateOperatorType options:[comparison options]];
    }
    
    [super setPredicate:predicate];
}




@end
