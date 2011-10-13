//
//  TrackTestAppDelegate.h
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <VVMIDI/VVMIDI.h>

@interface TrackTestAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
