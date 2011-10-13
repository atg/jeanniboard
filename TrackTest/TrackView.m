//
//  TrackView.m
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackView.h"
#import "NoteEvent.h"

int NumberOfKeysForOctaves(int octaves);
int MidiNoteForOctavePitch(int octave, int pitch);
void GenerateKeyboard(int octaves, NoteKey* notekeys);
NoteKey NearestKeyToPoint(NSPoint point, int octaves, NoteKey* notekeys);

int PitchForOctaveIndex(int index) {
#define o2p(a, b) case a: return b;
    
    switch (index) {
            o2p(0, 1);
            o2p(1, 3);
            o2p(2, 6);
            o2p(3, 8);
            o2p(4, 10);
            
            o2p(5, 0);
            o2p(6, 2);
            o2p(7, 4);
            o2p(8, 5);
            o2p(9, 7);
            o2p(10, 9);
            o2p(11, 11);
    }
    return 424242;
}

int NumberOfKeysForOctaves(int octaves) {
    return octaves * 12;
}
int MidiNoteForOctavePitch(int octave, int pitch) {
    return (60 - 12) + octave * 12 + pitch;
}
void GenerateKeyboard(int octaves, NoteKey* notekeys) {
    
    const int rows = octaves * 2;
    int i = 0;
    
    // row of 5, then row of 7, then row of 5, then row of 7...
    for (int row = 0; row < rows; row++) {
        
        int octave = row / 2;
        
        // Work out the Y coord
        // Divide 1.0 into |rows * 2| segments
        double ywidth = 1.0 / (rows * 2.0);
        
        // We want the (row * 2 + 1)th row
        double y = ywidth * (row * 2.0 + 1);
        
        // Work out the X coord
        int columns = (row % 2) == 0 ? 5 : 7;
        for (int column = 0; column < columns; column++) {
            
            double xwidth = 1.0 / (columns * 2.0);
            double x = xwidth * (column * 2.0 + 1);
            
            NoteKey key;
            key.octave = octave;
            key.pitch = PitchForOctaveIndex(i % 12);
            key.x = x;
            key.y = y;
            
            notekeys[i] = key;
            i++;
        }
    }
    
    
}
NoteKey NearestKeyToPoint(NSPoint point, int octaves, NoteKey* notekeys) {
    
    NoteKey nearestKey = notekeys[0];
    CGFloat distance = 42.0;
    for (int i = 0; i < octaves * 12; i++) {
        NoteKey key = notekeys[i];
        CGFloat thisDistance = sqrt(pow(point.x - key.x, 2.0) + pow(point.y - key.y, 2.0));
        if (thisDistance < distance) {
            nearestKey = key;
            distance = thisDistance;
        }
    }
    return nearestKey;
}

static void PrintKey(NoteKey key) {
    printf("key    { (%d, %d); (%lf, %lf) }\n", key.octave, key.pitch, key.x, key.y);
}
static void PrintKeyboard(int octaves, NoteKey* notekeys) {
    
    for (int i = 0; i < octaves * 12; i++) {
        NoteKey key = notekeys[i];
        PrintKey(key);
    }
    printf("\n---\n\n");
}

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
    
    // Generate a keyboard with 3 octaves
    octaves = 3;
    keyboard = calloc(sizeof(NoteKey), octaves * 12);
    GenerateKeyboard(octaves, keyboard);

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
        
//        NSLog(@"touchPoint = %@", NSStringFromPoint(touchPoint));
//        PrintKeyboard(octaves, keyboard);
        
        NSPoint kbpoint = touchPoint;
        kbpoint.y = 1.0 - kbpoint.y;
        NoteKey key = NearestKeyToPoint(kbpoint, octaves, keyboard);
        PrintKey(key);
        
//        NSLog(@"%d ? %d", MidiNoteForOctavePitch(key.octave, key.pitch), baseNote + position);
        
        NoteEvent *newNote = [[NoteEvent alloc] init];
        newNote.noteId = noteCounter++;
        newNote.note = MidiNoteForOctavePitch(key.octave, key.pitch);// baseNote + position
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
