//
//  NSDate+MoreDates.h
//  Magnesium
//
//  Created by Earl on 5/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface  NSDate (MoreDates)
- (NSDate *) dateAtDawn;
- (NSDate *) dateJustBeforeMidnight;
- (NSDate *) dateByOffsettingDays: (NSInteger) daysOffset;
- (NSDate *) dateByOffsettingMonths: (NSInteger) monthsOffset;
- (NSDate *) dateNextMonth;
- (NSDate *) firstDayOfTheYear;

- (BOOL) isSameDayAsDate : (NSDate *) otherDate;
- (NSDate *) lastDayOfTheYear;

- (NSDate *) nextDay;

- (NSInteger) weekday;

- (NSDate *) yesterday;
- (NSInteger)year;
- (NSInteger) daysSinceDate: (NSDate *) pastDate;
- (NSString *)dateStringWithStyle:(NSDateFormatterStyle)style;
- (NSString *)dateStringWithFormat: (NSString *) format;
@end
