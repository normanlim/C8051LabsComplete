//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab09: Load models with animations
//
//====================================================================

import SceneKit
import SwiftUI

// We will load an OBJ model without animation (a textured spider) and auto-rotate it,
//  as well as a DAE model with animation (a textured waving flag) that can toggle the animation

@Observable // This is needed to signal the SwiftUI View (or any other view) to be able to be signalled when something changes
class ModelLoadingExample: SCNScene {
    
    var buttonText: String      // Text for the toggle button, which we can change here and use the @Observable property to refresh the view

    var rotAngle = 0.0          // Keep track of rotation angle of rotating spider
    var rotateSpider = true     // Whether the spider is auto-rotating
    
    var flagLoc = Float(0.0)    // Keep track of placement of waving flag (we will auto-move it)
    var flagIncr = Float(0.05)  // How much to move flag each frame
    var animateFlag = true      // Whether the flag's waving animation is on or not
    
    var cameraNode = SCNNode()  // Initialize camera node
    var lastTime = CFTimeInterval(floatLiteral: 0)  // Used to calculate elapsed time on each update
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Initializer
    override init() {
        
        buttonText = "Turn off animation"
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        // Set up scene (camera, models, lights, etc.)
        setupCamera()
        loadModels()
        setupAmbientLight()
        
        // Setup the game loop tied to the display refresh
        let updater = CADisplayLink(target: self, selector: #selector(gameLoop))
        updater.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        updater.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        
    }
    
    
    // Function to setup the camera node
    func setupCamera() {
        
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(20, 20, 20)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0)
        rootNode.addChildNode(cameraNode)
        
    }
    
    
    // Load models
    func loadModels() {
        
        // Load the textured spider, at the origin, scaled properly
        let modelNode_Spider = loadModelFromFile(modelName: "spider", fileExtension: "obj")
        modelNode_Spider.position = SCNVector3(0, 0, 0)
        modelNode_Spider.scale = SCNVector3(0.05, 0.05, 0.05)
        rootNode.addChildNode(modelNode_Spider)
        
        // Load the waving flag, below the spider, scaled and rotated properly
        let modelNode_Flag = loadModelFromFile(modelName: "Weaving Flag", fileExtension: "dae")
        modelNode_Flag.position = SCNVector3(0, -25, 0)
        modelNode_Flag.scale = SCNVector3(4.0, 4.0, 4.0)
        modelNode_Flag.eulerAngles = SCNVector3(0, Float.pi/2, Float.pi/2)
        rootNode.addChildNode(modelNode_Flag)
        
    }
    
    
    // Load a model from the asset (file) and retun it in a SceneKit node reference
    func loadModelFromFile(modelName:String, fileExtension:String) -> SCNReferenceNode {
        
        let url = Bundle.main.url(forResource: modelName, withExtension: fileExtension)
        let refNode = SCNReferenceNode(url: url!)
        refNode?.load()
        refNode?.name = modelName
        return refNode!
        
    }
    
    
    // Sets up an ambient light (all around)
    func setupAmbientLight() {
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = UIColor.white
        ambientLight.light!.intensity = 5000
        rootNode.addChildNode(ambientLight)
        
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
        
        // if auto-rotate is on, update the rotation angle of the spider
        if (rotateSpider) {
            let modelNode_Spider = rootNode.childNode(withName: "spider", recursively: true)
            rotAngle += 0.01
            if rotAngle > 2*Double.pi {
                rotAngle -= 2*Double.pi
            }
            modelNode_Spider?.eulerAngles = SCNVector3(0, rotAngle, 0)
        }
        
        // move the flag, and set the animation status
        let modelNode_Flag = rootNode.childNode(withName: "Weaving Flag", recursively: true)
        flagLoc += flagIncr
        if ((flagLoc > 5.0) || (flagLoc < -5.0)) {
            flagIncr = -flagIncr
        }
        modelNode_Flag?.position.x = flagLoc
        modelNode_Flag?.isPaused = !animateFlag
        
    }
    
    
    // Function to be called by double-tap gesture: toggle spider auto-rotation
    @MainActor
    func handleDoubleTap() {
        rotateSpider = !rotateSpider
    }
    
    // Function to process button from SwiftUI that toggles animation (and updates the Button text)
    @MainActor
    func toggleAnimation() {
        if (animateFlag) {
            buttonText = "Turn on animation"
            animateFlag = false
        } else {
            buttonText = "Turn off animation"
            animateFlag = true
        }
    }
    
}
