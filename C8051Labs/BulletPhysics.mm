//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Objective-C++ wrapper for Bullet3D library
//
//====================================================================

#import "BulletPhysics.h"
#include "btBulletDynamicsCommon.h"
#include <stdio.h>
#include <map>
#include <string>
#include <chrono>

@interface BulletPhysics()
{

    // Bullet simulation objects
    btBroadphaseInterface *broadphase;
    btDefaultCollisionConfiguration *collisionConfiguration;
    btCollisionDispatcher *dispatcher;
    btSequentialImpulseConstraintSolver *solver;
    btDiscreteDynamicsWorld *dynamicsWorld;
    
    // Map to keep track of physics object to communicate with the renderer
    std::map<std::string, struct PhysicsObject3D *> physicsObjects;
}

@end

@implementation BulletPhysics

- (instancetype)init
{
    
    self = [super init];
    if (self) {
        
        // Set up Bullet3D
        broadphase = new btDbvtBroadphase();
        collisionConfiguration = new btDefaultCollisionConfiguration();
        dispatcher = new btCollisionDispatcher(collisionConfiguration);
        solver = new btSequentialImpulseConstraintSolver;
        dynamicsWorld = new btDiscreteDynamicsWorld(dispatcher,broadphase,solver,collisionConfiguration);
        dynamicsWorld->setGravity(btVector3(0,-10,0));
        
        // Set up the brick and ball objects
        struct PhysicsObject3D *newObj = new struct PhysicsObject3D;
        newObj->loc.x = BRICK3D_POS_X;
        newObj->loc.y = BRICK3D_POS_Y;
        newObj->loc.z = BRICK3D_POS_Z;
        newObj->objType = ObjTypeBox3D;
        char *objName = strdup("Brick");
        [self AddObject:objName newObject:newObj];
        
        newObj = new struct PhysicsObject3D;
        newObj->loc.x = BALL3D_POS_X;
        newObj->loc.y = BALL3D_POS_Y;
        newObj->loc.z = BALL3D_POS_Z;
        newObj->objType = ObjTypeSphere3D;
        objName = strdup("Ball");
        [self AddObject:objName newObject:newObj];
        
    }
    return self;
    
}


- (void)dealloc
{
    
    // Remove and delete each Bullet3D object
    for (auto const &b:physicsObjects) {
        dynamicsWorld->removeRigidBody((btRigidBody *)b.second->rigidBodyPtr);
        delete ((btRigidBody *)b.second->rigidBodyPtr)->getMotionState();
        delete ((btRigidBody *)b.second->rigidBodyPtr)->getCollisionShape();
        delete ((btRigidBody *)b.second->rigidBodyPtr);
    }
    
    // Delete Bullet3D setup objects
    delete dynamicsWorld;
    delete solver;
    delete collisionConfiguration;
    delete dispatcher;
    delete broadphase;
    
}


-(void)Update
{
    
    // Update the simulator
    dynamicsWorld->stepSimulation(1/60.f, 10);
    
    // Get pointers to the brick and ball physics objects
    // Update each node based on the new position from Bullet3D
    btTransform trans;
    btRigidBody *rbPtr;
    for (auto const &b:physicsObjects) {

        if (b.second && b.second->rigidBodyPtr) {

            rbPtr = (btRigidBody *)b.second->rigidBodyPtr;
            rbPtr->getMotionState()->getWorldTransform(trans);
            b.second->loc.x = trans.getOrigin().getX();
            b.second->loc.y = trans.getOrigin().getY();
            b.second->loc.z = trans.getOrigin().getZ();

        }

    }
    
}


-(void) AddObject:(char *)name newObject:(struct PhysicsObject3D *)newObj
{
    
    if (!newObj)
        return;

    // Default shape construction objects
    btCollisionShape *theShape;
    btDefaultMotionState *theMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1),
                                                                                btVector3(newObj->loc.x,
                                                                                          newObj->loc.y,
                                                                                          newObj->loc.z)));
    if (!theMotionState) return;
    btScalar mass = 0;
    btVector3 sphereInertia(0,0,0);

    // Based on the objType passed in, create a box or circle
    float restitution = 0.0f;
    switch (newObj->objType) {
            
        case ObjTypeBox3D:
            
            theShape = new btStaticPlaneShape(btVector3(0,1,0), BRICK3D_HEIGHT);
            if (!theShape) return;
            restitution = 0.5f;

            break;
            
        case ObjTypeSphere3D:
            
            theShape = new btSphereShape(BALL3D_RADIUS);
            if (!theShape) return;
            mass = 1;
            theShape->calculateLocalInertia(mass, sphereInertia);
            restitution = 1.0f;

            break;
            
        default:
            
            break;
            
    }
    
    // Create a new rigid body and add it to our world using the construction objects above
    btRigidBody::btRigidBodyConstructionInfo theRigidBodyCI(mass, theMotionState, theShape,sphereInertia);
    btRigidBody *theRigidBody = new btRigidBody(theRigidBodyCI);
    if (!theRigidBody) return;
    theRigidBody->setRestitution(restitution);
    dynamicsWorld->addRigidBody(theRigidBody);

    // Setup our physics object and store this object and the shape
    newObj->rigidBodyPtr = (void *)theRigidBody;
    newObj->bulletObj = (__bridge void *)self;
    physicsObjects[name] = newObj;
    
}


-(struct PhysicsObject3D *) GetObject:(const char *)name
{
    
    return physicsObjects[name];
    
}


-(void)Reset
{
    
    // Look up the ball object, delete it and reconstruct it
    struct PhysicsObject3D *theBall = physicsObjects["Ball"];
    if (!theBall) return;
    dynamicsWorld->removeRigidBody((btRigidBody *)theBall->rigidBodyPtr);
    delete ((btRigidBody *)theBall->rigidBodyPtr)->getMotionState();
    delete ((btRigidBody *)theBall->rigidBodyPtr)->getCollisionShape();
    delete ((btRigidBody *)theBall->rigidBodyPtr);

    PhysicsObject3D *newObj = new struct PhysicsObject3D;
    newObj->loc.x = BALL3D_POS_X;
    newObj->loc.y = BALL3D_POS_Y;
    newObj->loc.z = BALL3D_POS_Z;
    newObj->objType = ObjTypeSphere3D;
    char *objName = strdup("Ball");
    [self AddObject:objName newObject:newObj];
    
}


@end
