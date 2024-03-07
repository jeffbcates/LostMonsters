/*
 *  BoxListener.h
 *  iSurf
 *
 *  Created by Jeff Cates on 7/27/10.
 *  Copyright 2010 catesgroup llc. All rights reserved.
 *
 */

#import "Box2D.h"
#import "Actor.h"


/****EVENT CODE ***/

const int32 k_maxContactPoints = 2048;


struct ContactPoint
{
	b2Fixture* fixtureA;
	b2Fixture* fixtureB;
	b2Vec2 normal;
	b2Vec2 position;
	b2PointState state;
};


//Body Listener


class BoxListener : public b2ContactListener {
	CCLayer *parentLayer;
	b2World *world;
	
public:
	void SetParentScene(CCLayer *newLayer, b2World *newWorld) {
		//store a reference to parent layer so we can do cool stuff
		parentLayer = newLayer;
		world = newWorld;
	}
	
    void BeginContact(b2Contact* contact) {
		//get the two fixutres for the contact
		//and their bodies
		b2Fixture *fix1 = contact->GetFixtureA();
		b2Fixture *fix2 = contact->GetFixtureB();
		
		//get the two bodies
		b2Body *bod1 = fix1->GetBody();
		b2Body *bod2 = fix2->GetBody();
		
		//get two actors for those bodies
		Actor *actor1 = (Actor *)bod1->GetUserData();
		Actor *actor2 = (Actor *)bod2->GetUserData();
		
		//now... call each of those actors onBeginContact
		[actor1 onContactBegan:actor2];
		[actor2 onContactBegan:actor1];
	}
	
    void EndContact(b2Contact* contact) {
		//get the two fixutres for the contact
		//and their bodies
		b2Fixture *fix1 = contact->GetFixtureA();
		b2Fixture *fix2 = contact->GetFixtureB();
		
		//get the two bodies
		b2Body *bod1 = fix1->GetBody();
		b2Body *bod2 = fix2->GetBody();
		
		//get two actors for those bodies
		Actor *actor1 = (Actor *)bod1->GetUserData();
		Actor *actor2 = (Actor *)bod2->GetUserData();
		
		//now... call each of those actors onBeginContact
		[actor1 onContactEnd:actor2];
		[actor2 onContactEnd:actor1];
	}
	
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {	
	}
	
    void PostSolve(b2Contact* contact, b2ContactImpulse* impulse) {
	}
	
	
};