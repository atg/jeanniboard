//
//  FourByFourDrumpad.h
//  TrackTest
//
//  Created by Jean-Nicolas Jolivet on 11-10-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackLayout.h"

@interface FourByFourDrumpad : TrackLayout {
    NSMutableArray *notes;
    int noteCounter;
    NSMutableDictionary *noteDict;
}



@end
