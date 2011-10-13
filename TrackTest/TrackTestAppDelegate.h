//
//  TrackTestAppDelegate.h
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <VVMIDI/VVMIDI.h>

@class FourByFourDrumpad;


@interface TrackTestAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    VVMIDIManager *midiManager;
    
    FourByFourDrumpad *activeLayout;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) VVMIDIManager *midiManager;
@end
