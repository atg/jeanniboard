//
//  TrackView.h
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <VVMIDI/VVMIDI.h>
typedef enum _PadPosition {
    PadPositionTopLeft = 0,
    PadPositionTopRight,
    PadPositionBottomLeft,
    PadPositionBottomRight
} PadPosition;

typedef struct {
    int octave;
    int pitch;
    
    CGFloat x;
    CGFloat y;
    
} NoteKey;

@interface TrackView : NSView {
    VVMIDIManager *midiManager;
    NSMutableArray *notes;
    int noteCounter;
    
    NoteKey* keyboard;
    int octaves;
}


@end
