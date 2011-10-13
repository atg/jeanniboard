//
//  FourByFourDrumpad.m
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FourByFourDrumpad.h"
#import "NoteEvent.h"
#import "TrackTestAppDelegate.h"

@implementation FourByFourDrumpad

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
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
    
    return self;
}

- (void)dealloc
{
    [notes release];
    [noteDict release];
    [super dealloc];
}

- (void)touchEventBegan:(NSTouch *)touch
{
    NSPoint touchPoint = [touch normalizedPosition];
    
    int baseNote = 60;
    int funNote = floor(touchPoint.y * 100.0);
    int funNote2 = floor(touchPoint.x * 127.0);
    
    int xCoord = floor(touchPoint.x * 4.0);
    int yCoord = floor(touchPoint.y * 4.0);
    NSString *key = [NSString stringWithFormat:@"%dx%d", xCoord, yCoord];
    int noteValue = [[noteDict objectForKey:key] intValue];
    NSLog(@"XCord: %d", xCoord);
    
    NoteEvent *newNote = [[NoteEvent alloc] init];
    newNote.noteId = noteCounter++;
    //newNote.note = baseNote + position;
    newNote.note = noteValue;
    newNote.velocity = 90;
    newNote.touch = touch;
    [notes addObject:newNote];
    
    VVMIDIMessage *msg = nil;
    msg = [VVMIDIMessage createFromVals:
                        VVMIDINoteOnVal:
           1:
           newNote.note:
           newNote.velocity];
    if (msg != nil)
        [[[NSApp delegate] midiManager] sendMsg:msg];
    //NSLog(@"Sending: %@", [msg lengthyDescription]);
    [newNote release];
}

- (void)touchEventEnded:(NSTouch *)touch
{
    NSMutableArray *notesToDelete = [[[NSMutableArray alloc] init] autorelease];
    for (NoteEvent *aNote in notes) {
        if ([aNote.touch.identity isEqual:touch.identity]) {
            //NSLog(@"Found our note");
            //noteToDelete = aNote;
            [notesToDelete addObject:aNote];
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
            [[[NSApp delegate] midiManager] sendMsg:msg];
        
        //NSLog(@"Sending: %@", [msg lengthyDescription]);
        [notes removeObject:aNoteToDelete];
        
        
    }
}

@end
