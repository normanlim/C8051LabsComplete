//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab05: Add text that shows rotation angle of rotating cube
//        as well as 3D text
// *** WORKING VERSION (see //### comments)
//
//====================================================================

import SceneKit
import SwiftUI

class ControlableRotatingCrateWithText: SCNScene {
    var rotAngle = CGSize.zero // Keep track of drag gesture numbers
    var rot = CGSize.zero // Keep track of rotation angle
    var isRotating = true // Keep track of if rotation is toggled
    var cameraNode = SCNNode() // Initialize camera node
    var textX = 0.0
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer passing binding variable for the drag gesture numbers
    override init() {
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        addCube()
        addText()
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    // Function to setup the camera node
    func setupCamera() {
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        cameraNode.position = SCNVector3(5, 5, 5) // Set the position to (5, 5, 5)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0) // Set the pitch, yaw, and roll
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
    }
    
    // Create Cube
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        theCube.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "crate.jpg") // Diffuse the crate image material across the whole cube
        theCube.position = SCNVector3(0, 0, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
    }
    
    // Create 3D Text
    func addText() {
        let theText = SCNText(string: "Hello!", extrusionDepth: 1.0)    // Try changing extrusionDepth (thickness of the text)
        theText.flatness = 0.1  //### Lower value is smoother but can affect performance
        let theTextNode = SCNNode(geometry: theText)
        theTextNode.name = "Text"   //### This is necessary to look it up later in the scene to animate the text
        theTextNode.position = SCNVector3(x: 0, y: 0, z: 0) // Try changing these to move the text around
        theTextNode.scale = SCNVector3(0.1, 0.1, 0.1)   //### Without this the text is too big
        //### The next two lines moves the centre of rotation to be the centre of the text:
        let (minVec, maxVec) = theText.boundingBox
        theTextNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        rootNode.addChildNode(theTextNode) // Add the text object to the scene

        //### Repeat the above but this time for text we will use to track angles
        let dynamicText = SCNText(string: "123", extrusionDepth: 1.0)
        let dynamicTextNode = SCNNode(geometry: dynamicText)
        dynamicTextNode.name = "Dynamic Text"
        dynamicTextNode.position = SCNVector3(x: 0, y: -2.5, z: 0) // Position below the crate
        dynamicTextNode.scale = SCNVector3(0.03, 0.03, 0.03)
        dynamicTextNode.eulerAngles = cameraNode.eulerAngles    // Tie the rotation to the camera so it looks 2D
        dynamicTextNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        rootNode.addChildNode(dynamicTextNode) // Add the text object to the scene
    }

    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    @MainActor
    func reanimate() {
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name (This is where line 45 comes in)
        if (isRotating) {
            rot.width += 0.05 // Increment rotation of the cube by 0.0005 radians
            if (rot.width >= 2*Double.pi*50) {
                rot.width = 0.0
            }
        } else {
            rot = rotAngle // Let the rot variable follow the drag gesture
            if (rot.width >= 2*Double.pi*50) {
                rot.width = 0.0
            }
            if (rot.height >= 2*Double.pi*50) {
                rot.height = 0.0
            }
        }
        var rotX = Double(rot.height / 50)
        var rotY = Double(rot.width / 50)
        theCube?.eulerAngles = SCNVector3(rotX, rotY, 0) // Set the cube rotation to the numbers given from the drag gesture
        //### These lines rotate the text
        let theText = rootNode.childNode(withName: "Text", recursively: true)
        textX += 0.00005
        if (textX >= 2*Double.pi) {
            textX = 0.0
        }
        theText?.eulerAngles = SCNVector3(0, textX, 0)
        //### These lines set the dynamic text to report the rotation angles of the crate
        let dynamicTextNode = rootNode.childNode(withName: "Dynamic Text", recursively: true)
        if let textGeometry = dynamicTextNode?.geometry as? SCNText {
            rotX *= 180.0 / Double.pi
            rotY *= 180.0 / Double.pi
            textGeometry.string = String(format: "(%.2f,%.2f)", rotX, rotY)
            let (minVec, maxVec) = textGeometry.boundingBox
            dynamicTextNode?.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        }
        // Repeat increment of rotation every 10000 nanoseconds
        Task { try! await Task.sleep(nanoseconds: 10000)
            reanimate()
        }
    }
    
    @MainActor
    // Function to be called by double-tap gesture
    func handleDoubleTap() {
        isRotating = !isRotating // Toggle rotation
    }
    
    @MainActor
    // Function to be called by drag gesture
    func handleDrag(offset: CGSize) {
        rotAngle = offset // Get the width and height components of the CGSize, which only gives us two, and put them into the x and y rotations of the cube
    }
}
