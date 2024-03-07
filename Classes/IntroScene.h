//
//  LogoScene.h
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
//scene stuff and everything else
#import "BehavioralLayer.h"


/***OUR SCENES***/
//#import "TitleScreen.h"

/***MENU IMPLEMENTATION***/

@interface IntroScene : BehavioralLayer <BehavioralLayer> {
	//only call the intro done function once
	bool _introDone;
	
	//we don't allow skipping the first time
	bool _allowSkip;
	
	//scene level actors
	CCSpriteSheet *introSheet;
	Window *introMovie;
	bool _thoughtfulScene; //is the game scene we load the thoughtful one?
	
	
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
+(id) thoughtfulScene:(bool) thoughtful;
-(void) setThoughtful:(bool) thoughtful;

@end
