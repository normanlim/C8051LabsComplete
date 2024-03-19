//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab08: Add fog
//
//====================================================================

import SceneKit
import SwiftUI

class RotatingCrateFog: SCNScene {
    var rotAngle = 0.0 // Keep track of rotation angle
    var isRotating = true // Keep track of if rotation is toggled
    var cameraNode = SCNNode() // Initialize camera node
    var fogDensity = 9.0
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer
    override init() {
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        addCube()
        setupFog()
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    // Function to setup the camera node
    func setupCamera() {
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        cameraNode.position = SCNVector3(5, 5, 5) // Set the position to (0, 0, 2)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0) // Set the pitch, yaw, and roll to 0
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
    
    // Setup fog
    func setupFog() {
        fogColor = UIColor.cyan // Set fog colour to white
        fogStartDistance = 0 // The fog effect starts at z = 0
        fogEndDistance = 10 // The fog effect ends at z = 10
        fogDensityExponent = fogDensity // Set the function of distrubution of fog to nonic (The exponent is 9)
    }
    
    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    @MainActor
    func reanimate() {
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name (This is where line 43 comes in)
        if (isRotating) {
            rotAngle += 0.0005 // Increment rotation of the cube by 0.0005 radians
            // Keep the rotation angle in the range of 0 and pi
            if rotAngle > Double.pi {
                rotAngle -= Double.pi
            }
        }
        theCube?.eulerAngles = SCNVector3(0, rotAngle, 0) // Rotate cube by the final amount
        fogDensityExponent = fogDensity
        
        // Repeat increment of rotation every 10000 nanoseconds
        Task { try! await Task.sleep(nanoseconds: 10000)
            reanimate()
        }
    }
    
    @MainActor
    // Function to be called by double-tap gesture
    func handleDoubleTap() {
        isRotating = !isRotating // Toggle rotation
        fogDensity = 9
        print("Fog density = \(fogDensity)")
    }
    
    @MainActor
    // Function to be called by drag gesture
    func handleDrag(offset: CGSize) {
        fogDensity = fogDensity + offset.width / abs(offset.width)
    }
}
