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
    noteDict = [[NSMutableDictionary alloc] init];
    noteCounter = 0;
    
    //populate the note dict...
    int baseNum = 36;
    [noteDict setObject:[NSNumber numberWithInt:baseNum] forKey:@"0x0"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+1] forKey:@"1x0"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+2] forKey:@"2x0"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+3] forKey:@"3x0"];
    
    [noteDict setObject:[NSNumber numberWithInt:baseNum+4] forKey:@"0x1"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+5] forKey:@"1x1"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+6] forKey:@"2x1"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+7] forKey:@"3x1"];

    [noteDict setObject:[NSNumber numberWithInt:baseNum+8] forKey:@"0x2"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+9] forKey:@"1x2"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+10] forKey:@"2x2"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+11] forKey:@"3x2"];
    
    [noteDict setObject:[NSNumber numberWithInt:baseNum+12] forKey:@"0x3"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+13] forKey:@"1x3"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+14] forKey:@"2x3"];
    [noteDict setObject:[NSNumber numberWithInt:baseNum+15] forKey:@"3x3"];
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
        int funNote = floor(touchPoint.y * 100.0);
        int funNote2 = floor(touchPoint.x * 127.0);
        
        int xCoord = floor(touchPoint.x * 4.0);
        int yCoord = floor(touchPoint.y * 4.0);
        NSString *key = [NSString stringWithFormat:@"%dx%d", xCoord, yCoord];
        int noteValue = [[noteDict objectForKey:key] intValue];
        NSLog(@"XCord: %d", xCoord);
        
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
        //newNote.note = baseNote + position;
        newNote.note = noteValue;
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
