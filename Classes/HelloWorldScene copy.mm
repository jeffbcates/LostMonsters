//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Joe Free on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces

#import "HelloWorldScene.h"

//scenes
@class HelloMenu;


// HelloWorld implementation
@implementation HelloScene



+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloScene *layer = [HelloScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


// initialize your instance here
-(void) startScene
{
	//add a "gravity" behavior to the scene actor
	//this will cause the accelerometer to affect gravity		
	b2Vec2 startGravity;
	startGravity.Set(10,10);
	AccelGravity *grav = [AccelGravity alloc];
	[grav setFactor:startGravity];
	[sceneActor addBehavior:grav];
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2PolygonShape groundBox;		
	
	// bottom
	//note: ground is 25% wider thant he screen on each side
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top - JBC: note the top is 25% higher than the screen so things can fly off the screen before dying
	groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left - JBC: note the left side is 25% more to the left than the screen so things can fly off the left before dying
	groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right - JBC: note the right side is 25% more to the right than the screen so things can fly off to the right before dying
	groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	//add a behavor to repel all
	//Set up sprite
	blockSheet = [CCSpriteSheet spriteSheetWithFile:@"blocks.png" capacity:150];
	[self addChild:blockSheet z:0 tag:1];		
	
	//setup points counter on the screen
	CCLabel *Label2 = [CCLabel labelWithString:@"menu" fontName:@"Marker Felt" fontSize:16];
	Actor *Level2 = [[Actor alloc] init:self];
	[actors addObject:Level2];
	[Label2 setColor:ccc3(0,0,255)];
	Label2.position = ccp( screenSize.width - 50, screenSize.height-20);
	[self addChild:Label2];
	[Level2 setMainSprite:Label2];
	
	//first level loads first level
	TouchLoadScene *sceneLoader = [[TouchLoadScene alloc] init:[HelloMenu class]];
	[Level2 addBehavior:sceneLoader];	
	
}

-(b2Body *) addNewSpriteWithCoords:(CGPoint)p {
	//just randomly picking one of the images
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);


	ActorDef x = {
		type:1, 
		state:2, 
		mainSprite:[CCSprite spriteWithSpriteSheet:blockSheet rect:CGRectMake(0,0,40,40)], 
		mainBody:NULL,
		behaviors:[Behavior list:[FleeAll alloc], [Follow alloc] ]
	};
	
	int idx;
	float randX = CCRANDOM_0_1();
	if (randX < 0.25) idx = 0;
	if (randX >= 0.25 && randX < .5) idx = 1;
	if (randX >= .5 && randX < .75) idx = 2;
	if (randX >= .75 && randX < 1) idx = 3;
	
	CCSprite *sprite = [CCSprite spriteWithSpriteSheet:blockSheet rect:CGRectMake(40 * idx,40 * idy,40,40)];
	[blockSheet addChild:sprite];
	
	//determine type based on idx and idy
	
	sprite.position = ccp( p.x, p.y);
	
	Actor *newActor = [[Actor alloc] init:self];
	[newActor setState:0];
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	
	b2Body *body = world->CreateBody(&bodyDef);
	
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	
	//JBC: note 32 pixels = .5f, so figure out how wide in box2d 40 pixels is
	dynamicBox.SetAsBox(.5f/32*40, .5f/32*40);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	//create a new actor that stores the sprite and body	
	//bodyDef.userData = newActor;
	body->SetUserData(newActor);
	
	
	//actor stores the sprite body, type, and state	
	[newActor setType:idx*100 + idy*10];
	[newActor setMainBody:body];
	[newActor setMainSprite:sprite];
	
	//setup and add cascade touch behavior (will only cascade to same type blocks)
	CascadeTouch *tracker = [[CascadeTouch alloc] init];
	[tracker setCascades:true];
	[newActor addBehavior:tracker];
	
	//setup and add kill on touch behavior
	TouchKill *killer = [[TouchKill alloc] init];
	[newActor addBehavior:killer];
	
	//add this actor to the actor array
	[actors addObject:newActor];
	
	return body;
}

//what do we do when the user touches the scene? (not an actor)
- (void) onTouchBegan:(CGPoint) location {
	//for now just add a new sprite at the point of touch			
	[self addNewSpriteWithCoords:location];
}

//we need to implement default gravity here
//otherwise our scene will start with no graivty
-(b2Vec2) gravity {
	return b2Vec2(0.0f, -10.0f);
}



@end
