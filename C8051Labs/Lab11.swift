//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab11: Demo using Bullet3D for a ball that falls onto a ground plane
//
//====================================================================

import SceneKit

import QuartzCore

class Bullet3DDemo: SCNScene {
    
    var cameraNode = SCNNode()                      // Initialize camera node
    
    var lastTime = CFTimeInterval(floatLiteral: 0)  // Used to calculate elapsed time on each update
    
    var physicsStarted = false
    
    private var bulletPhys: BulletPhysics!                      // Points to Objective-C++ wrapper for C++ Bullet3D library

    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // Initializer
    override init() {
        
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        
        // Initialize the Bullet3D object
        bulletPhys = BulletPhysics()
        
        // Add the ball and the brick
        addBall()
        addBrick()

        // Setup the game loop tied to the display refresh
        let updater = CADisplayLink(target: self, selector: #selector(gameLoop))
        updater.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        updater.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        
    }

    
    // Initializer
    func initPhysics() {
        
        // Initialize the Bullet3D object
        bulletPhys = BulletPhysics()
        physicsStarted = true
        
    }

    
    // Function to setup the camera node
    func setupCamera() {
        
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        cameraNode.position = SCNVector3(0, 70, 70)
        cameraNode.look(at: SCNVector3(BRICK3D_POS_X, BRICK3D_POS_Y+30, BRICK3D_POS_Z))
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
        
    }
    
    
    func addBrick() {
        
        let theBrick = SCNNode(geometry: SCNBox(width: CGFloat(BRICK3D_WIDTH), height: CGFloat(BRICK3D_HEIGHT), length: CGFloat(BRICK3D_WIDTH), chamferRadius: 0))
        theBrick.name = "Brick"
        theBrick.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        theBrick.position = SCNVector3(Int(BRICK3D_POS_X), Int(BRICK3D_POS_Y), Int(BRICK3D_POS_Z))
        rootNode.addChildNode(theBrick)
        
    }
    
    
    func addBall() {
        
        let theBall = SCNNode(geometry: SCNSphere(radius: CGFloat(BALL3D_RADIUS)))
        theBall.name = "Ball"
        theBall.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        theBall.position = SCNVector3(Int(BALL3D_POS_X), Int(BALL3D_POS_Y), Int(BALL3D_POS_Z))
        rootNode.addChildNode(theBall)
        
    }

    
    // Simple game loop that gets called each frame
    @MainActor
    @objc
    func gameLoop(displaylink: CADisplayLink) {
        
        if (lastTime != CFTimeInterval(floatLiteral: 0)) {  // if it's the first frame, just update lastTime
            let elapsedTime = displaylink.targetTimestamp - lastTime    // calculate elapsed time
            updateGameObjects(elapsedTime: elapsedTime) // update all the game objects
        }
        lastTime = displaylink.targetTimestamp
        
    }
    
    
    @MainActor
    func updateGameObjects(elapsedTime: Double) {
        
        if (!physicsStarted) { return }
            
        // Update Bullet3D physics simulation
        bulletPhys.update()
        
        // Get ball position and update ball node
        let ballPos = UnsafePointer(bulletPhys.getObject("Ball"))
        let theBall = rootNode.childNode(withName: "Ball", recursively: true)
        theBall?.position.x = (ballPos?.pointee.loc.x)!
        theBall?.position.y = (ballPos?.pointee.loc.y)!
        theBall?.position.z = (ballPos?.pointee.loc.z)!
        
        // Get brick position and update brick node
        let brickPos = UnsafePointer(bulletPhys.getObject("Brick"))
        let theBrick = rootNode.childNode(withName: "Brick", recursively: true)
        theBrick?.position.x = (brickPos?.pointee.loc.x)!
        theBrick?.position.y = (brickPos?.pointee.loc.y)!
        theBrick?.position.z = (brickPos?.pointee.loc.z)!

    }
    
    
    // Function to be called by double-tap gesture: launch the ball
    @MainActor
    func handleDoubleTap() {
    }
    
    
    // Function to reset the physics (reset Box2D and reset the brick)
    @MainActor
    func resetPhysics() {

        bulletPhys.reset()
        
    }
    
}

