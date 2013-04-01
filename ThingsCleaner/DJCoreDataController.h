//
//  DJCoreDataController.h
//  ThingsCleaner
//
//  Created by Earl on 4/1/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Report;

@interface DJCoreDataController : NSObject
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, strong, nonatomic) NSURL *applicationFilesDirectory;
@property (readonly, strong, nonatomic) Report *lastReport;
@property (readonly, strong, nonatomic) Report *currentReport;
- (IBAction)saveAction:(id)sender;
+ (DJCoreDataController *)sharedController;
@end
