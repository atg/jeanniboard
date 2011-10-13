//
//  NoteEvent.h
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteEvent : NSObject {
    int note;
    int velocity;
    int noteId;
    NSTouch *touch;
}

@property (assign) int note;
@property (assign) int velocity;
@property (assign) int noteId;
@property (retain) NSTouch *touch;

@end
