//
//  Report+AdditionalMethods.h
//  Closer
//
//  Created by Earl on 1/26/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "Report.h"

@interface Report (AdditionalMethods)
@property (readonly,nonatomic) NSInteger subtotal; //returns the sum of points in the entries included
@property (readonly, nonatomic) NSDate *lastEntryDate; //completion date of the last entry
@end
