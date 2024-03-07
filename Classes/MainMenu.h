//
//  HelloWorldScene.h
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//
//	this is updated - right now


// When you import this file, you import all the cocos2d classes
//scene stuff and everything else
#import "BehavioralLayer.h"
#import "Window.h"
#import "LGSocialGamer.h"
//#import "GameKitHelper.h"

/***MENU IMPLEMENTATION***/

@interface MainMenu : BehavioralLayer <BehavioralLayer,LGSocialDelegate> { //, GameKitHelperProtocol> {
	//these values here let the notifications for unlocked monsters flow in slowly
	int currentUnlockedMonsters, targetUnlockedMonsters;
	
	//scene level actors
	CCSpriteSheet *menuSheet;
    
    //testing:
    Actor *test;
	
	//this is the text ccmenu
	CCMenu *menuItems;
	
	//when you click resume we need to remember which item
	//caused it to show so this is where we do that
	CCSprite *clickedMenu;
	
	//there is only 1 monster popup
	//and we replace the content as needed
	//that way we don't have two overlapping ones shown at once
	//Window *monsterPopup;
	bool showingPopup; //are we currently showing a monster? if so we shouldn't show another
	bool showIntro; //HACK: newCampaign method sets to true to force intro movie to show
	
	//reference to window that displays all monsters on the screen
	Window *monsterMenu;
	
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
+(id) sceneNoMusic;

//we respond to this selector when popup menus are closed
//that way we can gracefully disable touch events on us while its open
-(void) popupWindowClosed:(Actor *) window;

//we respond to this selector when the user wants to resume an existing campaign
-(void) resumeCampaign:(Actor *) menuItem;

//called from monster popups
-(void) bragAboutMonster:(Actor *) bragButton;

@end
