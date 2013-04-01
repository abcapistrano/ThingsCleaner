//
//  DJEntry.h
//  Closer
//
//  Created by Earl on 1/26/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Report;

@interface DJEntry : NSManagedObject

@property (nonatomic, retain) NSDate * completionDate;
@property (nonatomic, retain) NSDate * maturityDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSString * projectName;
@property (nonatomic, retain) Report *report;

@end
