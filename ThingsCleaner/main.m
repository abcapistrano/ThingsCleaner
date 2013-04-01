//
//  main.m
//  ThingsCleaner
//
//  Created by Earl on 4/1/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DJAppDelegate.h"
int main(int argc, char *argv[])
{
    NSApplication * application = [NSApplication sharedApplication];
    DJAppDelegate *delegate = [[DJAppDelegate alloc] init];
    [application setDelegate:delegate];
    [application run];

    return EXIT_SUCCESS;


}
