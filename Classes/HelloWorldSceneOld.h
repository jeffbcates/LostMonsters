//
//  HelloWorldScene.h
//  testapp
//
//  Created by Joe Free on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h" 
#import "GLES-Render.h"
#import "BoxListener.h"
#import "Actor.h"
#import "Behaviors.h"

@protocol BehavioralScene
//a scene can contain its own behaviors
@property(nonatomic,readonly) CCArray *behaviors;

//scene should have a list of actors
@property(nonatomic,readonly) CCArray *actors;	

//return the world
@property(nonatomic, readonly) b2World *world;

//remove an actor from the scene
//including its bodies and sprites
-(void) removeActor:(Actor *) actor;


@end


@interface BehavioralScene : CCLayer <BehavioralScene>
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
	
	//create a centralized object that the blocks will move toward
	b2Fixture* attractor;
	
	//list of actors within the scene
	//and list of "dirty" actors to destroy
	//the reason we do this is the "removeActor" method may get called
	//at a time when the actor cannot be destroyed because we are in a loop / etc	
	//this ensures that all calls to destroy the actor are always done at a safe time
	CCArray *actors;
	CCArray *dyingActors;
	
	//a scene can contain behaviors itself
	//the reason we use an actor here is because it already has
	//logic that splits up the different event types 
	Actor *sceneActor;
}

//scene should have a list of behaviors (assigned just to the scene)
@property(nonatomic,readonly) CCArray *behaviors;	

//scene should have a list of actors
@property(nonatomic,readonly) CCArray *actors;	

//return the world
@property(nonatomic, readonly) b2World *world;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

// adds a new sprite at a given coordinate
-(b2Body *) addNewSpriteWithCoords:(CGPoint)p;
-(void) addPoints:(int)newPoints;
-(void) failedGame;

//remove an actor from the scene
//including its bodies and sprites
-(void) removeActor:(Actor *) actor;

//kill actors marked to kill
//should not be called externally

-(void) killActors;


@end
