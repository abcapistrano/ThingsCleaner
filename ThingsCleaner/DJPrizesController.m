//
//  DJPrizesController.m
//  ThingsCleaner
//
//  Created by Earl on 4/1/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "DJPrizesController.h"
#import "Report+AdditionalMethods.h"
#import "Things.h"
#import "NSDate+MoreDates.h"
#import "MTRandom.h"
#import "DJCoreDataController.h"
#import <YAMLFramework/YAMLFramework.h>
@implementation DJPrizesController


+ (id)sharedController
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });



    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {

        NSURL* constantsURL = [[DJCoreDataController sharedController].applicationFilesDirectory URLByAppendingPathComponent:@"Constants.yaml"];
        _constants = [YACYAMLKeyedUnarchiver unarchiveObjectWithFile:[constantsURL path]];

        NSURL* prizesURL = [[DJCoreDataController sharedController].applicationFilesDirectory URLByAppendingPathComponent:@"Prizes.yaml"];
        _prizes = [YACYAMLKeyedUnarchiver unarchiveObjectWithFile:[prizesURL path]];

    }
    return self;
}

- (void) makePrizes {

    ThingsApplication* _thingsApp = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.things"];


    Report *report = [DJCoreDataController sharedController].currentReport;
    ThingsArea *prizesArea = [_thingsApp.areas objectWithName:@"Prizes"];


    NSPredicate *pred = [NSPredicate predicateWithFormat:@"status == %@", [NSAppleEventDescriptor descriptorWithEnumCode:ThingsStatusOpen]];
    NSUInteger existingPrizesCount = [[prizesArea.toDos filteredArrayUsingPredicate:pred] count];



    
    NSUInteger maxPrizesCount = [self.constants[@"MAX_PRIZES_COUNT"] integerValue];
    
    if (existingPrizesCount) {
        return; // don't make prizes if there are existing prizes. exhaust them first.
    }

    NSUInteger prizeCost = [self.constants[@"PRIZES_COST"] integerValue]; //1 prize for every three points
    NSUInteger numberOfPrizesToMake = MIN(maxPrizesCount - existingPrizesCount, report.totalPoints.integerValue/prizeCost);



    NSURL *biasedPrizesURL = [[DJCoreDataController sharedController].applicationFilesDirectory URLByAppendingPathComponent:@"Biased Prizes.yaml"];
    NSMutableArray *biasedPrizes = [YACYAMLKeyedUnarchiver unarchiveObjectWithFile:[biasedPrizesURL path]];

    NSUInteger count = [biasedPrizes count];
    if (count == 0 || count < numberOfPrizesToMake ) {

        biasedPrizes = [NSMutableArray array];

        [self.prizes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSDictionary* prize, NSUInteger idx, BOOL *stop) {

            NSString *bias = prize[@"bias"];
            NSUInteger iteration = 0;

            if ([bias isEqualToString:@"high"]) {

                iteration = [self.constants[@"HIGH_PRIZES_DENSITY"] integerValue];


            } else if ([bias isEqualToString:@"normal"]) {

                iteration = [self.constants[@"NORMAL_PRIZES_DENSITY"] integerValue];


            } else if ([bias isEqualToString:@"low"]) {

                iteration = [self.constants[@"LOW_PRIZES_DENSITY"] integerValue];

                
            }

            for (NSUInteger i = 0; i<iteration; i++) {
                [biasedPrizes addObject:prize];
            }
            
          
            
        }];



       


        
    }


  
    Class todoClass = [_thingsApp classForScriptingClass:@"to do"];
    SBElementArray *toDos = prizesArea.toDos;


    NSArray* sampledPrizes = [biasedPrizes grab:numberOfPrizesToMake];

    [sampledPrizes enumerateObjectsUsingBlock:^(NSDictionary* prize, NSUInteger idx, BOOL *stop) {
        ThingsToDo *toDo = [todoClass new];
        [toDos addObject:toDo];

        toDo.name = prize[@"activityName"];
        toDo.tagNames = prize[@"tag"];

        toDo.dueDate = [[[NSDate date] dateByOffsettingDays:30] dateJustBeforeMidnight]; //prizes expire in 30 days.
    }];


    // add the prize deduction

    if (numberOfPrizesToMake > 0) {


        ThingsList *logbook = [_thingsApp.lists objectWithName:@"Logbook"];
        SBElementArray *loggedToDos = logbook.toDos;
        
        
        ThingsToDo *toDo = [todoClass new];
        [loggedToDos addObject:toDo];
        
        NSUInteger pointsUsed = prizeCost * numberOfPrizesToMake;
        toDo.name = [NSString stringWithFormat:@"Prize. -%lu", pointsUsed];
        
        
    }

    _prizesMade = numberOfPrizesToMake;
    
    NSString *yaml = [biasedPrizes YACYAMLEncodedString];
    [yaml writeToURL:biasedPrizesURL atomically:YES encoding:NSUTF8StringEncoding error:nil];

};

@end
