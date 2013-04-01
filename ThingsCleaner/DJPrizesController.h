//
//  DJPrizesController.h
//  ThingsCleaner
//
//  Created by Earl on 4/1/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJPrizesController : NSObject
@property (readonly, strong, nonatomic) NSDictionary * constants;
@property (readonly, strong, nonatomic) NSArray *prizes;

@property (readonly, nonatomic) NSUInteger prizesMade;
+ (DJPrizesController *)sharedController;
- (void) makePrizes;
@end
