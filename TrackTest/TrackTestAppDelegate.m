//
//  TrackTestAppDelegate.m
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackTestAppDelegate.h"
#import "NoteEvent.h"
#import "FourByFourDrumpad.h"

@implementation TrackTestAppDelegate

@synthesize window, midiManager;

- (id)init {
    if (self = [super init]) {
        NSLog(@"Init");
        VVMIDIManager *aMidiManager = [[VVMIDIManager alloc] init];
        self.midiManager = aMidiManager;
        activeLayout = [[FourByFourDrumpad alloc] init];
        [aMidiManager release];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    // watch for an event...
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskGesture 
                                          handler:^ NSEvent * (NSEvent *event) {
                                              NSSet *beganTouches = [event touchesMatchingPhase:NSTouchPhaseBegan
                                                                                         inView:nil];
                                              
                                              NSSet *endTouches = [event touchesMatchingPhase:NSTouchPhaseEnded 
                                                                                       inView:nil];
                                              
                                              
                                              if ([beganTouches count] > 0) {
                                                  
                                                  for (NSTouch *aBeginTouch in beganTouches) {
                                                      NSLog(@"Begin...");
                                                      [activeLayout touchEventBegan:aBeginTouch];
                                                  }
                                              }
                                              
                                              if ([endTouches count] > 0) {
                                                  for (NSTouch *anEndTouch in endTouches) {
                                                      [activeLayout touchEventEnded:anEndTouch];
                                                  }
                                              }
                                              
                                              return event;
                                          }];
    
}



@end
