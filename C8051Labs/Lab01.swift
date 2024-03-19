//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab01: Draw red square using SceneKit
//
//====================================================================

import SceneKit

class RedSquare: SCNScene {
    var cameraNode = SCNNode() // Initialize camera node
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer
    override init() {
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        addSquare()
    }
    
    // Function to setup the camera node
    func setupCamera() {
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        cameraNode.position = SCNVector3(0, 0, 2) // Set the position to (0, 0, 2)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0) // Set the pitch, yaw, and roll to 0
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
    }
    
    // Function to create a red square
    func addSquare() {
        let theSquare = SCNNode(geometry: SCNPlane(width: 1, height: 1)) // Create a object node of plane shape with width of 1 and height of 1
        theSquare.geometry?.firstMaterial?.diffuse.contents = UIColor.red // Set the square's texture to a solid red (we will learn more about this in future labs)
        theSquare.position = SCNVector3(0, 0, 0) // Set the square's position to (0, 0, 0)
        rootNode.addChildNode(theSquare) // Add the square node to the scene
    }
}
