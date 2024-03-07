//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Joe Free on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces

#import "SecondScene.h"
#import "HelloMenu.h"

// HelloWorld implementation
@implementation SecondScene


+(id) scene;
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SecondScene *layer = [SecondScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


// initialize your instance here
-(void) startScene
{
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
	blockSheet = [CCSpriteSheet spriteSheetWithFile:@"bubbles.png" capacity:150];
	[self addChild:blockSheet z:0 tag:1];		
	
	//start with just 3 types
	maxTypes = 3;
	
	
	
	//*****MENUS*****//
	//setup points counter on the screen
	CCLabel *Label2 = [CCLabel labelWithString:@"menu" fontName:@"Marker Felt" fontSize:16];
	Actor *Level2 = [[Actor alloc] init:self];
	[actors addObject:Level2];
	[Label2 setColor:ccc3(0,0,255)];
	Label2.position = ccp( screenSize.width - 50, screenSize.height-20);
	[self addChild:Label2];
	[Level2 setMainSprite:Label2];
	
	//first level loads first level
	TouchLoadScene *sceneLoader = [[TouchLoadScene alloc] withScene:[HelloMenu class]];
	[Level2 addBehavior:sceneLoader];	


	//setup points counter on the screen
	CCLabel *LabelPoints = [CCLabel labelWithString:@"points: 0" fontName:@"Marker Felt" fontSize:16];
	points = [[Actor alloc] init:self];
	[actors addObject:points];
	[LabelPoints setColor:ccc3(0,0,255)];
	LabelPoints.position = ccp( 50, screenSize.height-20);
	[self addChild:LabelPoints];
	[points setMainSprite:LabelPoints];
	
	//setup a "points" behavior
	[points addBehavior:[TrackPoints alloc]];	
	
	//setup starting spawn count and spawn interval values
	spawnCount = SPAWN_COUNT_START;
	spawnInterval = SPAWN_INTERVAL_START;
	
	//scehdule a level up for 30 seconds from now
	[self schedule:@selector(levelUp) interval:30.0f];
	
	//add a random actor
	[self addRandomSprite];
	
	
}


-(void) gameOver {
	CCLabel *LabelPoints = [CCLabel labelWithString:@"GAME OVER" fontName:@"Marker Felt" fontSize:48];
	Actor *OverActor = [[Actor alloc] init:self];
	[actors addObject:OverActor];
	[LabelPoints setColor:ccc3(0,0,255)];
	LabelPoints.position = ccp( [self screenSize].width/2, [self screenSize].height/2);
	[self addChild:LabelPoints];
	[OverActor setMainSprite:LabelPoints];
	[self addActor:OverActor];
	[[CCDirector sharedDirector] pause ];
}

-(void) addRandomSprite {
	//local declarations
	DLOG(@"SecondScene: start addRandomSprite");
	static int spawnedActors = 0;
	
	//if at any point we have too many actors
	//the game is over
	if ([[self actors] count] > 100) {
		//game is over
		[self gameOver];
		
	}
	
	
	//get a random set of coords for the new sprite
	float x = CCRANDOM_0_1() * 400 + 40;
	float y = CCRANDOM_0_1() * 280 + 20;
	CGPoint coords = CGPointMake(x,y);
	
	//add a new sprite with random coords
	Actor * newActor = [self addNewSpriteWithCoords:coords];

	//depending on settings... try different things
	//add some behaviors to the new actor
	[newActor withBehaviors:
		[[TrackContact alloc] init],
	 
		//TODO: testing code - try either immediate only bubbles or all bubbles of the same color
		(immediateOnlyCache) ? 
			[[[CascadeTouch alloc] withPreventTouch:3] withImmediateOnly] : 
	 		[[[CascadeTouch alloc] withPreventTouch:3] withMatchingType],
		//END TODO: testing code - try either immediate only bubbles or all bubbles of the same color
	 
		[[UpdateColorType alloc] withMaxTypes:maxTypes],
		[[[AutoPoint alloc] withTracker:points] withMinActors:10],
		[[[Animate alloc] init] withTouchEnabled],
		nil
	 ];
	
	//add impulse contact behavior
	//but schedule it to get removed shortly afterwards (just pushes other blocks out of the way
	//FleeAll * fleer = [[[ImpulseContactBehavior alloc] withPush] withForce:1];
	//[newActor addBehavior:fleer];
	//[newActor performSelector:@selector(removeBehavior:) withObject:fleer afterDelay:0.25f];
	
	//as long as spawned actors is not zero, quickly add another one
	if (spawnedActors < spawnCount) {
		//schedule a shorter delay
		[self schedule:@selector(addRandomSprite) interval:0.15f];
		
		//there is one more actor
		spawnedActors++;
		
	} else {
		//schedule a longer delay
		[self schedule:@selector(addRandomSprite) interval:spawnInterval];
		
		//reset spawn count
		spawnedActors = 0;
		
		//decrease spawn interval for next time
		if (spawnInterval > SPAWN_INTERVAL_MIN) spawnInterval -= SPAWN_INTERVAL_REDUCER;
		
	}

	//wea re done
	DLOG(@"SecondScene: end addRandomSprite");
}

-(void) levelUp {
	//abort if max types is 5
	if (maxTypes >= 5) return;
	
	//make things harder
	maxTypes += 1;
	
	//schedule for 30 seconds from now
	[self schedule:@selector(levelUp) interval:30.0f];
}


-(Actor *) addNewSpriteWithCoords:(CGPoint)p {
	//just randomly picking one of the images
	int idx;
	float randX =  CCRANDOM_0_1() * (maxTypes-1);
	idx = round(randX);  //auto round
	
	CCSprite *sprite = [CCSprite spriteWithSpriteSheet:blockSheet rect:CGRectMake(40 * 0,40 * 0,40,40)];
	[blockSheet addChild:sprite]; 
	[sprite setColor:(ccColor3B) {
			r:255 * ((idx==0 || idx==3 || idx==4) ? 1 : 0), 
			g:255 * ((idx==1 || idx==3 ) ? 1 : 0), 
			b:255 * ((idx==2 || idx==4) ? 1 : 0)
	}];
		
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
	//b2PolygonShape dynamicBox;
	b2CircleShape dynamicBox;
	
	//JBC: note 32 pixels = .5f, so figure out how wide in box2d 40 pixels is
	dynamicBox.m_radius = .5f;
	//dynamicBox.SetRadius(.5f/32*40);
	//dynamicBox.SetAsBox(.5f/32*40, .5f/32*40);//These are mid points for our 1m box
	
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
	[newActor setType:idx];
	[newActor setMainBody:body];
	[newActor setMainSprite:sprite];
	

	//add this actor to the actor array
	[actors addObject:newActor];
	
	//return the actor we created
	return newActor;
}



//what do we do when the user touches the scene? (not an actor)
- (void) onTouchBegan:(CGPoint) location {
	//for now just add a new sprite at the point of touch			
	//[self addNewSpriteWithCoords:location];
}

//we need to implement default gravity here
//otherwise our scene will start with no graivty
-(b2Vec2) gravity {
	return b2Vec2(0.0f, -10.0f);
}

//behaviors property implementation
-(CCArray *) behaviors {
	//return scene actors behaviors
	return [sceneActor behaviors];
}

//our dealloc method
-(void) dealloc {
	//release actors
	
	//release ourselves
	[super dealloc];
}


-(void) configure:(bool) immediateOnly {
	//update scene settings
	immediateOnlyCache = immediateOnly;
}

@end
