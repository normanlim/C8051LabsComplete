//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab06: Add diffuse light
//
//====================================================================

import SceneKit
import SwiftUI

class RotatingCrateLight: SCNScene {
    var rotAngle = 0.0 // Keep track of rotation angle
    var isRotating = true // Keep track of if rotation is toggled
    var cameraNode = SCNNode() // Initialize camera node
    var diffuseLightPos = SCNVector4(0, 0, 0, Double.pi/2) // Keep track of diffuse light position
    
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
        setupAmbientLight() // try commenting out this line
        setupDirectionalLight()
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
    
    // Sets up an ambient light (all around)
    func setupAmbientLight() {
        let ambientLight = SCNNode() // Create a SCNNode for the lamp
        ambientLight.light = SCNLight() // Add a new light to the lamp
        ambientLight.light!.type = .ambient // Set the light type to ambient
        ambientLight.light!.color = UIColor.white // Set the light color to white
        ambientLight.light!.intensity = 5000 // Set the light intensity to 5000 lumins (1000 is default)
        rootNode.addChildNode(ambientLight) // Add the lamp node to the scene
    }
    
    // Sets up a directional light
    func setupDirectionalLight() {
        let directionalLight = SCNNode() // Create a SCNNode for the lamp
        directionalLight.name = "Directional Light" // Name the node so we can reference it later
        directionalLight.light = SCNLight() // Add a new light to the lamp
        directionalLight.light!.type = .directional // Set the light type to directional
        directionalLight.light!.color = UIColor.green // Set the light color to white
        directionalLight.light!.intensity = 20000 // Set the light intensity to 20000 lumins (1000 is default)
        directionalLight.rotation = diffuseLightPos // Set the rotation of the light to the position variable
        rootNode.addChildNode(directionalLight) // Add the lamp node to the scene
    }
    
    // Create Cube
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        theCube.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "crate.jpg") // Diffuse the crate image material across the whole cube
        theCube.position = SCNVector3(0, 0, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
    }
    
    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    @MainActor
    func reanimate() {
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name (This is where line 69 comes in)
        if (isRotating) {
            rotAngle += 0.0005 // Increment rotation of the cube by 0.0005 radians
            // Keep the rotation angle in the range of 0 and pi
            if rotAngle > Double.pi {
                rotAngle -= Double.pi
            }
        }
        theCube?.eulerAngles = SCNVector3(0, rotAngle, 0) // Rotate cube by the final amount
        let directionalLight = rootNode.childNode(withName: "Directional Light", recursively: true) // Get the cube object by its name (See line 56)
        directionalLight?.rotation = diffuseLightPos
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
        diffuseLightPos = SCNVector4(offset.height, offset.width, 0, Double.pi/2) // Get the width and height components of the CGSize, which only gives us two, and put them into the x and y rotations of the light
    }
}
