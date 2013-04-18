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
    [_thingsApp emptyTrash];
    
    ThingsArea *prizesArea = [_thingsApp.areas objectWithName:@"Prizes"];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"status == %@", [NSAppleEventDescriptor descriptorWithEnumCode:ThingsStatusOpen]];
    NSUInteger existingPrizesCount = [[prizesArea.toDos filteredArrayUsingPredicate:pred] count];

    NSUInteger maxPrizesCount = [self.constants[@"maxPrizesCount"] integerValue];
    NSUInteger prizesCost = [self.constants[@"prizesCost"] integerValue];


    Report *report = [DJCoreDataController sharedController].currentReport;
    NSUInteger numberOfPrizesToMake = MIN(maxPrizesCount - existingPrizesCount, report.totalPoints.integerValue/prizesCost);
    NSMutableArray *pool = [NSMutableArray array];
    NSArray *prizes = self.constants[@"prizes"];
    [prizes enumerateObjectsUsingBlock:^(NSDictionary* prizeInfo, NSUInteger idx, BOOL *stop) {

        double power = (idx+1)/1.5;
        double bias = floor(pow(2,power));


        for (NSUInteger i = 0; i < bias; i++) {

            [pool addObject:prizeInfo];


        }

    }];
    NSArray* sampledPrizes = [pool.shuffledArray sample:numberOfPrizesToMake];

    Class todoClass = [_thingsApp classForScriptingClass:@"to do"];
    SBElementArray *toDos = prizesArea.toDos;

    [sampledPrizes enumerateObjectsUsingBlock:^(NSDictionary* prize, NSUInteger idx, BOOL *stop) {
        ThingsToDo *toDo = [todoClass new];
        [toDos addObject:toDo];

        toDo.name = prize[@"name"];
        toDo.tagNames = prize[@"tag"];

        toDo.dueDate = [[[NSDate date] dateByOffsettingDays:[self.constants[@"shelfLife"] integerValue]] dateJustBeforeMidnight];
    }];


    // add the prize deduction

    ThingsList *logbook = [_thingsApp.lists objectWithName:@"Logbook"];
    SBElementArray *loggedToDos = logbook.toDos;




    if (numberOfPrizesToMake) {
        ThingsToDo *toDo = [todoClass new];
        [loggedToDos addObject:toDo];
        
        NSUInteger pointsUsed = prizesCost * numberOfPrizesToMake;
        toDo.name = [NSString stringWithFormat:@"Prize. -%lu", pointsUsed];
    }

    _prizesMade = numberOfPrizesToMake;




};

@end
