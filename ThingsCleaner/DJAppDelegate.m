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
#import "DJCoreDataController.h"
#import "Report+AdditionalMethods.h"
#import "DJEntry+AdditionalMethods.h"
#import "MTRandom.h"
#import "NSString+GenericString.h"
#import "DJPrizesController.h"

NSString * const LAST_SCAN_DATE_KEY = @"lastScanDate";
@implementation DJAppDelegate {

    ThingsApplication *_thingsApp;
    DJCoreDataController *_coreDataController;


}

- (id)init
{
    self = [super init];
    if (self) {
        _thingsApp = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.things"];
        _coreDataController = [[DJCoreDataController alloc] init];


    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    [self makeReport];
    [[DJPrizesController sharedController] makePrizes];
    [self cleanUp];



    NSUserNotification *note = [NSUserNotification new];
    note.title = @"Things Cleaner";
    note.informativeText = [NSString stringWithFormat:@"Current Points:%@\nPrizes Made:%lu", _coreDataController.currentReport.totalPoints, [DJPrizesController sharedController].prizesMade];

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];
    [NSApp terminate:self];

    
}

- (void) makeReport {

    ThingsList *logbook = [_thingsApp.lists objectWithName:@"Logbook"];
    SBElementArray *toDos = logbook.toDos;
    Report *lastReport = [_coreDataController lastReport];


    NSDate *lastScanDate = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_SCAN_DATE_KEY];

    if (lastScanDate == nil) {
        
        lastScanDate = [[NSDate date] dateAtDawn];

    }
    NSPredicate *completionDatePredicate = [NSPredicate predicateWithFormat:@"completionDate > %@",  lastScanDate];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_SCAN_DATE_KEY];

    [toDos filterUsingPredicate:completionDatePredicate];
    NSArray *filteredTodos = [[toDos get] mutableCopy];

    // Iterate over the todos

    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"^.+\\. ([-+]?\\d+)$" options:0
                                                                      error:NULL];

    MTRandom *randomizer = [[MTRandom alloc] init];

    void (^inspectToDos)(ThingsToDo *, NSUInteger, BOOL *) = ^(ThingsToDo* toDo, NSUInteger idx, BOOL *stop) {

        if (toDo.status == ThingsStatusCompleted) {
            NSString *toDoName = toDo.name;

            NSTextCheckingResult *result = [exp firstMatchInString:toDoName options:0 range:NSMakeRange(0, [toDoName length])];

            if (result) {
                NSRange pointRange = [result rangeAtIndex:1];
                NSInteger rawPoints = [[toDoName substringWithRange:pointRange] integerValue];


                DJEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:_coreDataController.managedObjectContext];
                NSRange nameRange = NSMakeRange(0, pointRange.location-1);

                entry.name = [toDoName substringWithRange:nameRange];
                entry.points = @(rawPoints);
                entry.projectName = toDo.project.name;
                entry.completionDate = toDo.completionDate;



                // if the entry is a routine or school work..it matures immediately
                NSString *area = toDo.area.name;
                if (!area) area = toDo.project.area.name;


                //bonuses and routines are realized immediately
                if ([toDo.tagNames containsSubstring:@"routine"] || [toDo.tagNames containsSubstring:@"bonus"]) {

                    entry.maturityDate = toDo.completionDate;
                    entry.points = @(rawPoints);

                } else if ([area isEqualToString:@"School Work"]) {

                    //2x points for school work.


                    entry.maturityDate = toDo.completionDate;
                    entry.points =  @(2 * rawPoints);
                }

                else if (rawPoints < 0){

                    // we're dealing with timewasters here

                    entry.points = @(rawPoints);
                    entry.maturityDate = toDo.completionDate;



                } else {


                    // shuffle the maturity dates for other entries between 30 days from 90 days of the current date


                    NSDateComponents *dc = [[NSDateComponents alloc] init];

                    //get a random number from
                    NSInteger randomDay = [randomizer randomUInt32From:30 to:90];
                    [dc setDay:randomDay];
                    NSDate *maturityDate = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:toDo.completionDate options:0];

                    entry.maturityDate = maturityDate;

                }




            }


        }

    };

    [filteredTodos enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:inspectToDos];

    // if the entry is a project we should inspect the todos inside
    NSMutableArray *todosHidingInsideProjects = [NSMutableArray array];
    
    NSArray *completedProjects = [_thingsApp.projects filteredArrayUsingPredicate:completionDatePredicate];
    [completedProjects enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ThingsProject* project, NSUInteger idx, BOOL *stop) {
        SBElementArray *todos = [project toDos];
        [todos filterUsingPredicate:completionDatePredicate];
        NSArray *local = [todos get];
        [todosHidingInsideProjects addObjectsFromArray:local];
        //  NSLog(@"%@",project.name);
        
    }];
    [todosHidingInsideProjects enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:inspectToDos];


    ///////////////////// POPULATE THE CURRENT REPORT /////////////////

    

    Report *currentReport =_coreDataController.currentReport;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];

    NSDate *beginDate = lastReport.lastEntryDate;
    if (beginDate == nil) {
        beginDate = lastReport.closingDate;
    }
    if (beginDate == nil) {
        beginDate = [[NSDate date] dateAtDawn]; //to deal with the scenario when there is no report yet
    }

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"maturityDate >%@ AND maturityDate < %@", beginDate, currentReport.closingDate];
    [request setPredicate:pred];

    NSArray *results = [_coreDataController.managedObjectContext executeFetchRequest:request error:nil];
    [currentReport addEntries:[NSSet setWithArray:results]];
    
    currentReport.totalPoints = @(currentReport.subtotal + lastReport.totalPoints.integerValue);
    [_coreDataController saveAction:self];


}






- (void) cleanUp {
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
    
    
}

@end
