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

  
    }
    return self;
}

- (void) makePrizes {

    ThingsApplication* _thingsApp = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.things"];


    ThingsArea *prizesArea = [_thingsApp.areas objectWithName:@"Prizes"];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"status == %@", [NSAppleEventDescriptor descriptorWithEnumCode:ThingsStatusOpen]];
    NSUInteger existingPrizesCount = [[prizesArea.toDos filteredArrayUsingPredicate:pred] count];
    existingPrizesCount = 0;
    if (existingPrizesCount) {
        return; // don't make prizes if there are existing prizes. exhaust them first.
    }

    NSUInteger maxPrizesCount = [self.constants[@"maxPrizesCount"] integerValue];
    NSUInteger poolSize = [self.constants[@"poolSize"] integerValue];
    NSUInteger prizesCost = [self.constants[@"prizesCost"] integerValue];


    Report *report = [DJCoreDataController sharedController].currentReport;
    NSUInteger numberOfPrizesToMake = MIN(maxPrizesCount - existingPrizesCount, report.totalPoints.integerValue/prizesCost);


    NSMutableArray *pool = [NSMutableArray arrayWithCapacity:poolSize];
    NSDictionary *prizes = self.constants[@"prizes"];
    [prizes enumerateKeysAndObjectsUsingBlock:^(NSString* bias, NSDictionary* prizeInfo, BOOL *stop) {
        NSArray *activities = prizeInfo[@"activities"];
        NSUInteger activityCount = [activities count];
        double percentage = [prizeInfo[@"percentage"] doubleValue] / 100;


        NSUInteger countPerActivity = ceil((poolSize * percentage) / activityCount);

        NSLog(@"%f %lu", percentage, countPerActivity);


        [activities enumerateObjectsUsingBlock:^(NSDictionary* activityInfo, NSUInteger idx, BOOL *stop) {

            for (NSUInteger i = 0; i < countPerActivity; i++) {

                [pool addObject:activityInfo];

            }


        }];


    }];

    
    NSArray* sampledPrizes = [pool sample:numberOfPrizesToMake];

    Class todoClass = [_thingsApp classForScriptingClass:@"to do"];
    SBElementArray *toDos = prizesArea.toDos;

    [sampledPrizes enumerateObjectsUsingBlock:^(NSDictionary* prize, NSUInteger idx, BOOL *stop) {
        ThingsToDo *toDo = [todoClass new];
        [toDos addObject:toDo];

        toDo.name = prize[@"activityName"];
        toDo.tagNames = prize[@"tag"];

        toDo.dueDate = [[[NSDate date] dateByOffsettingDays:30] dateJustBeforeMidnight]; //prizes expire in 30 days.
    }];


    // add the prize deduction

    ThingsList *logbook = [_thingsApp.lists objectWithName:@"Logbook"];
    SBElementArray *loggedToDos = logbook.toDos;


    ThingsToDo *toDo = [todoClass new];
    [loggedToDos addObject:toDo];

    NSUInteger pointsUsed = prizesCost * numberOfPrizesToMake;
    toDo.name = [NSString stringWithFormat:@"Prize. -%lu", pointsUsed];
    

    _prizesMade = numberOfPrizesToMake;

};

@end
