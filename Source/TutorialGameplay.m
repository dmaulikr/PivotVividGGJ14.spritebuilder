//
//  TutorialGameplay.m
//  PivotVividGGJ14
//
//  Created by Benjamin Encz on 24/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "TutorialGameplay.h"
#import "TutorialFragment.h"
#import "Level.h"
#import "GameState.h"

// TODO: this can only be used for prototype
static int _currentFragmentIndex;

@implementation TutorialGameplay {
    NSMutableArray *_tutorialFragments;
    CCLabelTTF *_instructionLabel;
    NSString *_tutorialName;
    NSArray *_fragmentNames;
}

- (void)didLoadFromCCB {
    self.level = [[Level alloc] init];
    
    [super didLoadFromCCB];
    
    
    /* Load the last active tutorial step. If a player doesn't pass a tutorial step he will have to repeat it*/
    NSDictionary *tutorialInfo = [[GameState sharedInstance] currentLevelInfo];
    _tutorialName = tutorialInfo[@"levelName"];
    _fragmentNames = tutorialInfo[@"tutorialFragments"];
    
    [self restoreCurrentTutorialFragment];
}

#pragma mark - Load Tutorial Fragement

- (NSString *)currentFragmentCCBName {
    NSString *currentFragmentName = _fragmentNames[_currentFragmentIndex];
    NSString *fragmentCCBFile = [NSString stringWithFormat:@"Tutorials/%@/%@", _tutorialName, currentFragmentName];
    
    return fragmentCCBFile;
}

- (void)restoreCurrentTutorialFragment {
    NSString *fragmentCCBFile = [self currentFragmentCCBName];
    
    // add a little blank level before the tutorial fragment so player can prepare
    CCNode *tutorialPreplay = (TutorialFragment *) [CCBReader load:@"Fragments/Tutorial_blank"];
    [self.level addChild:tutorialPreplay];
    
    //TODO: instead of looping fragment twice add blank space afterwards?
    TutorialFragment *tutorialFragment1 = (TutorialFragment *) [CCBReader load:fragmentCCBFile];
    tutorialFragment1.position = ccp(tutorialPreplay.contentSize.width, 0);
    [self.level addChild:tutorialFragment1];
    self.delegate = tutorialFragment1;
    
    TutorialFragment *tutorialFragment2 = (TutorialFragment *) [CCBReader load:fragmentCCBFile];
    tutorialFragment2.position = ccp(tutorialFragment1.position.x + tutorialFragment1.contentSize.width, 0);
    [self.level addChild:tutorialFragment2];
    
    _tutorialFragments = [@[tutorialFragment1, tutorialFragment2] mutableCopy];
    
    // update instruction
    _instructionLabel.string = NSLocalizedString(tutorialFragment1.instruction, nil);
    
    /* since we dynamically loaded new blocks to the world we need to call findBlocks again to collect these new blocks.
     The game needs to know about all blocks to be able to apply moods, etc. */
    [super findBlocks:self.level];
}

#pragma mark - Next Tutorial Step

- (void)nextTutorialStep {
    if ((_currentFragmentIndex+1) < [_fragmentNames count]) {
        _currentFragmentIndex++;
    }
    _instructionLabel.string = @"Well done!";
}

#pragma mark - Inform Delegate

- (void)jump {
    [super jump];
    
    if ([self.delegate respondsToSelector:@selector(tutorialGameplayJumped:)]) {
        [self.delegate tutorialGameplayJumped:self];
    }
}

- (void)switchMood {
    [super switchMood];
    
    if ([self.delegate respondsToSelector:@selector(tutorialGameplayChangedMood:)]) {
        [self.delegate tutorialGameplayChangedMood:self];
    }
}

#pragma mark - Overriden Gameplay Methods

- (void)endGame {
    [self restartLevel];
}

- (void)restartLevel {
    // reload level
    [super stopMusic];
    CCScene *scene = [CCBReader loadAsScene:@"TutorialGameplay"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)update:(CCTime)delta {
    [super update:delta];
    
    // loop tutorial fragments
    for (int i = 0; i < [_tutorialFragments count]; i++) {
        TutorialFragment *fragment = _tutorialFragments[i];
        
        // get the world position of the fragment
        CGPoint fragmentWorldPosition = [self.level convertToWorldSpace:fragment.position];
        // get the screen position of the fragment
        CGPoint fragmentScreenPosition = [self convertToNodeSpace:fragmentWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        if (fragmentScreenPosition.x <= (-1 * fragment.contentSize.width)) {
            // workaround for compound static physics objects not beeing movable
            CCNode *parent = fragment.parent;
            CGPoint fragmentPosition = fragment.position;
            CGSize fragmentSize = fragment.contentSize;
            [fragment removeFromParent];
            
            if ([fragment respondsToSelector:@selector(tutorialGameplayCompletedFragment:)]) {
                [fragment tutorialGameplayCompletedFragment:self];
            }
            
            TutorialFragment *otherFragment = (i == 0) ? _tutorialFragments[1] : _tutorialFragments[0];
            
            fragment = _tutorialFragments[i] = (TutorialFragment *) [CCBReader load:[self currentFragmentCCBName]];
            fragment.position = ccp(otherFragment.position.x + otherFragment.contentSize.width, fragmentPosition.y);
            [parent addChild:fragment];
            self.delegate = fragment;
            _instructionLabel.string = NSLocalizedString(fragment.instruction, nil);
            
            [super findBlocks:fragment];
        }
    }
}

@end
