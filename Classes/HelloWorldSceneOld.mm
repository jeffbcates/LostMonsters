//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Joe Free on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces

#import "HelloWorldScene.h"



// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagSpriteSheet = 1,
	kTagAnimation1 = 1,
};




//scene level actors
CCSpriteSheet *blockSheet;

int spawnCountDown;
int spawnInitialStartPoint = 30;
int spawnStartPoint = spawnInitialStartPoint; //every 5 seconds
int spawnCountDownMod = 0; //each time a monkey spawns it gets faster by this amount

int contactID = 1;
BoxListener *bx;

//track basics like banana count
CCLabel	*pointsLabel;
int points=0;

//starting posotiion for touchs
CGPoint touchStart;
bool actorTouched = false;
b2Body *touchedBody;


// HelloWorld implementation
@implementation BehavioralScene
@synthesize actors, world;


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BehavioralScene *layer = [BehavioralScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//here a monkey died so we start over 
-(void) failedGame {
	//just start over for now
	points = 0;
	[pointsLabel setString:@"You Lose"];
	
	//start the counter
	spawnStartPoint = spawnInitialStartPoint;	
}

//add a number of points
-(void) addPoints:(int) newPoints {
	//add to the points
	points += newPoints;
	
	//get the points label
	NSString *newPointsLabel = [NSString stringWithFormat:@"Points: %i",points];
	
	//update the label
	[pointsLabel setString:newPointsLabel];
}

// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
		
		//create a new CCArray of actors
		//and a placeholder array for 
		actors = [[CCArray alloc] init];
		dyingActors = [[CCArray alloc] init];
		
		//create our scene actor pointed back to us
		sceneActor = [[Actor alloc] init:self];
		
		//add a "gravity" behavior to the scene actor
		//this will cause the accelerometer to affect gravity		
		b2Vec2 startGravity;
		startGravity.Set(10,10);
		AccelGravity *grav = [AccelGravity alloc];
		[grav setFactor:startGravity];
		[sceneActor addBehavior:grav];

		//create a new box listener
		bx = new BoxListener();
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.

		world = new b2World(gravity, doSleep);
		
		//store references back to us within the box listener
		bx->SetParentScene(self, world);
		
		world->SetContinuousPhysics(true);
		world->SetContactListener(bx);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		spawnCountDown = 0;
		
		uint32 flags = 0;
		//flags += b2DebugDraw::e_shapeBit;
		flags += b2DebugDraw::e_jointBit;
		//flags += b2DebugDraw::e_aabbBit;
		//flags += b2DebugDraw::e_pairBit;
		//flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
				
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
		[self addChild:blockSheet z:0 tag:kTagSpriteSheet];		

		//[self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
		
		//setup points counter on the screen
		pointsLabel = [CCLabel labelWithString:@"Points: 0" fontName:@"Marker Felt" fontSize:16];
		points = 0; //start with no points
		[self addChild:pointsLabel z:0];
		[pointsLabel setColor:ccc3(0,0,255)];
		pointsLabel.position = ccp( screenSize.width - 50, screenSize.height-20);
		
		
		
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

-(b2Body *) addNewSpriteWithCoords:(CGPoint)p {
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithSpriteSheet:blockSheet rect:CGRectMake(32 * idx,32 * idy,32,32)];
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
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
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
	//[newActor setState:MONKEY_FALLING];
	[newActor setMainBody:body];
	[newActor setMainSprite:sprite];
	
	TrackContacts *tracker = [[TrackContacts alloc] init];
	
	//yes...cascade to all touched actors that respond to track contacts
	[tracker setCascades:true];
	
	//add the behavior
	[newActor addBehavior:tracker];
	
	
	/*
	if ( [actors count] != 0) {
		//create a new actor and give it no behaviors
		//create an actor that flees everyone
		Follow *follower = [Follow alloc];
		[follower setOther:[actors objectAtIndex:[actors count]-1]];
		[follower setForce:1];
		[newActor addBehavior:follower];
	} 
	
	FleeAll *fleer = [FleeAll alloc];
	[fleer setOthers:actors];
	[newActor addBehavior:fleer];	
	 */

	//add this actor to the actor array
	[actors addObject:newActor];
	
	return body;
}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
	
	//step through all the actors in our scene
	//and sync their sprites with their bodies
	for (uint c= 0; c < [actors count]; c++ ) {
		//make this actor behave
		[[actors objectAtIndex:c] onTick];
		
		//sync this actor
		[[actors objectAtIndex:c] sync];
	}
	
	//it is safe to kill actors now
	//note: we couldn't do it before in case we were in a step operation
	[self killActors];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//that's it - we just get the starting position of the touch
	//when touches end we launch the correct actor in the direction
	//of the end of the touch
	bool actorTouched = false;
	
	//when touches start we need to check all touches just in case one of the overlaps the sprite
	//and one does not - due to fat fingering from the user

	
	//can we detect if the ship sprite was touched here?	
	//testing... run through all blocks
	//and find the one that was touched	
	//NOTE: there is probably a faster way to do this (using box2d?)
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		//note: touch position is not right
		CGPoint location = [touch locationInView: [touch view]];
		location = CGPointMake(location.y, location.x);				
		
		//run through all bodies in the world		
		for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
			if (b->GetUserData() != NULL) {
				Actor *a = (Actor *)b->GetUserData();
				
				//Synchronize the AtlasSprites position and rotation with the corresponding body
				CCSprite *myActor = [a mainSprite];
				
				CGPoint pos = myActor.position;  //CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
				
				//did this block get touched?
				//NOTE: we give a fudge factor of 25% so you don't have to exactly touch inside the sprite
				//NOTE: just changed fudge factor to 0%
				if ( location.x >= pos.x - myActor.contentSize.width*.25 && location.x <= pos.x + myActor.contentSize.width * 1.25 &&
					location.y >= pos.y - myActor.contentSize.height *.25 && location.y <= pos.y + myActor.contentSize.height *1.25 )  {
					//this actor was touched
					[a onTouchBegan];
					
					//an actor was touched
					actorTouched = true;
					
				} 
			}	
			
		}
		//if an actor was not touched, then maybe we were touched
		if (!actorTouched) {
			//fire ontouch event for all behaviors that support it
			//this gets fired on our actor
			[sceneActor onTouchBegan];
			
			//for now just add a new sprite at the point of touch			
			[self addNewSpriteWithCoords:location];
			
		}
	}
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {	
	//step through each actor and allow it to respond
	//to acceleration
	for (uint c=0; c < [actors count]; c++ ) {
		//call this actors onAccelerate method
		Actor *a = [actors objectAtIndex:c];
		[a onAccelerate:acceleration];
		
	}
	
	//the scene can also respond
	//through the use of a "scene actor"
	[sceneActor onAccelerate:acceleration];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}

//this actually cremates the actors in a safe way
-(void) killActors {
	//kill all dying actors
	while ([dyingActors count] > 0) {
		//get this actor reference
		//and kill the scene reference
		Actor *actor = [dyingActors objectAtIndex:0];

		//remove the actor from actor list and dying actor list
		[actors removeObject:actor];	
		[dyingActors removeObject:actor];

		//get references to body and sprite
		CCSprite *sprite = [actor mainSprite];
		b2Body *body = [actor mainBody];
		
		//remove the actors body and sprite
		world->DestroyBody(body);
		[blockSheet removeChild:sprite cleanup:YES];

		//free memory for the actor
		[actor dealloc];
	}
	
	
}

//remove an actor from the scene
//including its bodies and sprites
-(void) removeActor:(Actor *) actor {
	//add the actor (once) to the dyning actor list
	if ([dyingActors containsObject:actor]) return;
	
	//schedule the actor to be removed
	//by adding to death row
	[dyingActors addObject:actor];
	
}

//our behaviors are the behaviors on our scene actor
-(CCArray *) behaviors {
	//return our behaviors
	return [sceneActor behaviors];
}


@end
