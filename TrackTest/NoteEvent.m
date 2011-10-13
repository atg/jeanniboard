//
//  NoteEvent.m
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteEvent.h"

@implementation NoteEvent


@synthesize note, velocity, noteId, touch;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)isEqual:(NoteEvent *)object {
    return self.noteId == object.noteId;
}

@end
