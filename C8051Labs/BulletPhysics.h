//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Objective-C++ wrapper for Bullet3D library
//
//====================================================================

#import <Foundation/Foundation.h>


// Set up brick and ball physics parameters here:
//   position, width/height/length (or radius)

#define BRICK3D_POS_X         0.0f
#define BRICK3D_POS_Y         5.0f
#define BRICK3D_POS_Z         0.0f
#define BRICK3D_WIDTH         50.0f
#define BRICK3D_HEIGHT        5.0f
#define BALL3D_POS_X            0.0f
#define BALL3D_POS_Y            70.0f
#define BALL3D_POS_Z            0.0f
#define BALL3D_RADIUS            2.0f


// You can define other object types here
typedef enum { ObjTypeBox3D=0, ObjTypeSphere3D=1 } ObjectType3D;


// Location of each object in our physics world
struct PhysicsLocation3D {
    float x, y, z;
};


// Information about each physics object
struct PhysicsObject3D {

    struct PhysicsLocation3D loc; // location
    ObjectType3D objType;         // type
    void *rigidBodyPtr;           // pointer to Bullet rigid body definition
    void *bulletObj;              // pointer to the Bullet object for use in callbacks
};


@interface BulletPhysics: NSObject

-(void)Update;
-(void) AddObject:(char *)name newObject:(struct PhysicsObject3D *)newObj;    // Add a new physics object
-(struct PhysicsObject3D *) GetObject:(const char *)name;                     // Get a physics object by name
-(void) Reset;                                                              // Reset Box2D

@end
