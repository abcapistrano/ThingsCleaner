//
//  DJAppDelegate.m
//  ThingsCleaner
//
//  Created by Earl on 4/1/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "DJAppDelegate.h"
#import "Things.h"
#import "NSDate+MoreDates.h"
@implementation DJAppDelegate {

    ThingsApplication *_thingsApp;

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    // delete entries in the log book which are more than a month old


    _thingsApp = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.things"];
    NSDate *aMonthAgo = [[NSDate date] dateByOffsettingMonths:-1];;



    NSPredicate *pred = [NSPredicate predicateWithFormat:@"completionDate < %@", aMonthAgo];

    ThingsList *logbook = [_thingsApp.lists objectWithName:@"Logbook"];
    SBElementArray *toDos = logbook.toDos;
    [toDos filterUsingPredicate:pred];

    [toDos arrayByApplyingSelector:@selector(delete)];


    // delete overdue prizes

    ThingsArea *prizesArea = [_thingsApp.areas objectWithName:@"Prizes"];
    NSPredicate *overDue = [NSPredicate predicateWithFormat:@"status == %@ AND dueDate < %@", [NSAppleEventDescriptor descriptorWithEnumCode:ThingsStatusOpen], [NSDate date] ];
    SBElementArray *overDuePrizes = prizesArea.toDos;
    [overDuePrizes filterUsingPredicate:overDue];
    [overDuePrizes arrayByApplyingSelector:@selector(delete)];

    // clear the trash

    [_thingsApp emptyTrash];

    [NSApp terminate:self];

    
}

@end
