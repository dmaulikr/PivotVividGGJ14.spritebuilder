//
//  GroundBlockEight.h
//  PivotVividGGJ14
//
//  Created by Benjamin Encz on 25/01/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSpriteBatchNode.h"

@class Mood;

@interface GroundBlockEight : CCSprite

- (void)applyMood:(Mood*)mood;

@property (nonatomic, strong) NSString *onlyVisibleInMood;


@end
