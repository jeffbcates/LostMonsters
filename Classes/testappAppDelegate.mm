//
//  testappAppDelegate.m
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//

#import "testappAppDelegate.h"
#import "cocos2d.h"
#import "LogoScene.h"
#import "Settings.h"
#import "RootViewController.h"
#import "OpenFeint/OpenFeint.h"
#import "LGSocialGamer.h"

//related to pausing in the middle of a game
#import "FranticScene.h"

@implementation testappAppDelegate

@synthesize window;



- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	RootViewController * viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
	
	// Turn on display FPS
	[director setDisplayFPS:NO];
	
	
	// Turn on multiple touches
	EAGLView *view = [director openGLView];
	
	//do notallow multi touch on this particular game
	[view setMultipleTouchEnabled:NO];
	
	//enable or disable sound based on settings
	//[[SimpleAudioEngine sharedEngine] setEnabled:[Settings getSoundEnabled]];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:view];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	//can only set root view controller starting with 4.0
	if ( [LGSocialGamer deviceAtVersion:@"4.0"] ) {
		// Must add the root view controller for GameKitHelper to work!
		[window setRootViewController:viewController];
	}
	
	[window makeKeyAndVisible];
	
	//counts as an app launch
	[LGSocialGamer appLaunched];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		
	[[CCDirector sharedDirector] runWithScene: [LogoScene scene]];	
	
}


//save the current game if possible
-(void) saveCurrentGame {
	//save our level as needed
	if ( [[[CCDirector sharedDirector] runningScene] isKindOfClass:[FranticScene class]] ) {
		//launch our paused menu but keep the 
		FranticScene *playScene = (FranticScene *) [[CCDirector sharedDirector] runningScene];
		[playScene triggerSave];
	}
		
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//pause the director
	[[CCDirector sharedDirector] pause];
	
	//save the current game
	[self saveCurrentGame];
	
	//let social gaming know we are no longer active
	//[LGSocialGamer appPaused];
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	//resume directory
	[[CCDirector sharedDirector] resume];

	//only show the paused dialog if we were in "frantic" mode
	if ( [[[CCDirector sharedDirector] runningScene] isKindOfClass:[FranticScene class]] ) {
		//launch our paused menu but keep the 
		FranticScene *playScene = (FranticScene *) [[CCDirector sharedDirector] runningScene];
		[playScene triggerPause];
	}
	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	//save the current level if possible
	[self saveCurrentGame];
	
	//stop the directory
	[[CCDirector sharedDirector] end];
	
	//save user defaults (openfeint and our settings)
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
