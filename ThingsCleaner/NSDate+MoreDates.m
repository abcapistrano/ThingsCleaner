//
//  NSDate+MoreDates.m
//  Magnesium
//
//  Created by Earl on 5/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSDate+MoreDates.h"



@implementation NSDate (MoreDates)

- (NSDate *) dateAtDawn {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit)
                                                                   fromDate:self];
    [components setSecond:0];
    [components setHour:0];
    [components setMinute:0];
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *) dateJustBeforeMidnight {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit)
                                                                   fromDate:self];
    [components setSecond:59];
    [components setHour:23];
    [components setMinute:59];
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}


- (NSDate *) nextDay {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[self dateAtDawn] options:0];
}

- (NSDate *) yesterday {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[self dateAtDawn] options:0];
}

- (BOOL) isSameDayAsDate : (NSDate *) otherDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit)
                                                                   fromDate:self];
    NSDateComponents *otherDateComponents = [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit)
                                                                            fromDate:otherDate];
    
    
    return  ([components year] == [otherDateComponents year]) &&
    ([components month] == [otherDateComponents month]) &&
    ([components day] == [otherDateComponents day]);
    
    
}

- (NSDate *) dateByOffsettingDays: (NSInteger) daysOffset {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daysOffset];
    return [[NSCalendar currentCalendar]
            dateByAddingComponents:components
            toDate:[self dateAtDawn]
            options:0];
}

- (NSDate *) firstDayOfTheYear {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit) fromDate:self];
    [components setDay:1];
    [components setMonth:1];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *) lastDayOfTheYear {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:[NSDate date]];
    [components setDay:31];
    [components setMonth:12];
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}


- (NSInteger)year {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self];
    return [components year];
}

- (NSDate *) dateByOffsettingMonths: (NSInteger) monthsOffset {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:monthsOffset];
    return [[NSCalendar currentCalendar]
            dateByAddingComponents:components
            toDate:[self dateAtDawn]
            options:0];
}
- (NSDate *) dateNextMonth {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:1];
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self options:0];
}

- (NSInteger) weekday {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self];
    return [components weekday];
}


- (NSInteger) daysSinceDate: (NSDate *) pastDate {
    NSDateComponents * difference = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                                    fromDate:pastDate
                                                                      toDate:self
                                                                     options:0];
    return [difference day];
    
    
}

- (NSString *)dateStringWithStyle:(NSDateFormatterStyle)style
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:style];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dateStringWithFormat: (NSString *) format {
/*
 see: http://www.cocoawithlove.com/2009/05/simple-methods-for-date-formatting-and.html and http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns for formats
 
 */

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:format];
   return [dateFormatter stringFromDate:self];
}




@end
