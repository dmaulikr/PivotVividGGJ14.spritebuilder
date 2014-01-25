//
//  Hero.h
//  PivotVividGGJ14
//
//  Created by Benjamin Encz on 24/01/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "CCAnimatedSprite.h"

@interface Hero : CCAnimatedSprite

@property (nonatomic, assign) CGPoint previousPosition;
@property (nonatomic, assign) float speed;

@end
