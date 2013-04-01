//
//  Report+AdditionalMethods.m
//  Closer
//
//  Created by Earl on 1/26/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "Report+AdditionalMethods.h"
#import "NSDate+MoreDates.h"
#import "DJEntry+AdditionalMethods.h"
@implementation Report (AdditionalMethods)
- (void) awakeFromInsert {

    [super awakeFromInsert];
    self.closingDate = [[NSDate date] dateJustBeforeMidnight];

}

- (NSInteger) subtotal {

    return [[self.entries valueForKeyPath:@"@sum.points"] integerValue];
}

- (NSDate *) lastEntryDate {

    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"completionDate" ascending:YES];
    NSArray *entries = [self.entries.allObjects sortedArrayUsingDescriptors:@[sd]];

    return [(DJEntry*)[entries lastObject] completionDate];

}



@end
