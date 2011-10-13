//
//  TrackView.m
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackView.h"
#import "NoteEvent.h"

@implementation TrackView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"Called");
        // Initialization code here.
        [self setAcceptsTouchEvents:YES];
    }
    
    return self;
}
- (void)awakeFromNib {
    [self setAcceptsTouchEvents:YES];
    midiManager = [[VVMIDIManager alloc] init];
    notes = [[NSMutableArray alloc] init];
    noteCounter = 0;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}


- (void)mouseDown:(NSEvent *)theEvent {
    VVMIDIMessage *msg = nil;
    msg = [VVMIDIMessage createFromVals:
                 VVMIDIControlChangeVal:
           1:
           123:
           0];
    [midiManager sendMsg:msg];
    NSLog(@"Sending: %@", [msg lengthyDescription]);
}


- (void)touchesBeganWithEvent:(NSEvent *)event {
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseBegan inView:self];
    for (NSTouch *aTouch in touches) {
        
        NSPoint touchPoint = [aTouch normalizedPosition];

        int baseNote = 60;
        PadPosition position;
        if (touchPoint.x < 0.5 && touchPoint.y < 0.5) {
            position = PadPositionBottomLeft;
            
        } else if(touchPoint.x >= 0.5 && touchPoint.y < 0.5) {
            position = PadPositionBottomRight;
        } else if(touchPoint.x < 0.5 && touchPoint.y >= 0.5) {
            position = PadPositionTopLeft;
        } else if(touchPoint.x >= 0.5 && touchPoint.y >= 0.5) {
            position = PadPositionTopRight;
        }
        NoteEvent *newNote = [[NoteEvent alloc] init];
        newNote.noteId = noteCounter++;
        newNote.note = baseNote + position;
        newNote.velocity = 90;
        newNote.touch = aTouch;
        [notes addObject:newNote];
        
        
        VVMIDIMessage *msg = nil;
        msg = [VVMIDIMessage createFromVals:
               VVMIDINoteOnVal:
               1:
               newNote.note:
               newNote.velocity];
        if (msg != nil)
            [midiManager sendMsg:msg];
        //NSLog(@"Sending: %@", [msg lengthyDescription]);
        [newNote release];
    }
    
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseEnded inView:self];
    NoteEvent *noteToDelete = nil;
    NSMutableArray *notesToDelete = [[[NSMutableArray alloc] init] autorelease];
    for (NoteEvent *aNote in notes) {
        for (NSTouch *aTouch in touches) {
            if ([aNote.touch.identity isEqual:aTouch.identity]) {
                //NSLog(@"Found our note");
                //noteToDelete = aNote;
                [notesToDelete addObject:aNote];
            } 
            
        }
    }
    
    
    for (NoteEvent *aNoteToDelete in notesToDelete) {
        VVMIDIMessage *msg = nil;
        msg = [VVMIDIMessage createFromVals:
                           VVMIDINoteOffVal:
               1:
               aNoteToDelete.note:
               0];
        if (msg != nil)
            [midiManager sendMsg:msg];
        
        //NSLog(@"Sending: %@", [msg lengthyDescription]);
        [notes removeObject:aNoteToDelete];
            
        
    }
    
    //NSLog(@"Count (notes | touches): %d | %d", [notes count], [touches count]);

}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    //NSLog(@"Touch Moved");
}



@end
