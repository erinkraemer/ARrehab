//
//  ViewController.swift
//  ARrehab
//
//  Created by Eric Wang on 2/12/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

var Floor: Entity?
//var subARview: ARView!

class ViewController: UIViewController {
    
    /// AR View
    @IBOutlet var arView: ARView!
    
    var visualizedPlanes : [ARPlaneAnchor] = []
    var activeButtons : [UIButton] = []
    var trackedRaycasts : [ARTrackedRaycast?] = []
    
    var boardState : BoardState = .notMapped
    
    var tileGrid: TileGrid?
    var gameBoard: GameBoard?
    
    var name : ViewController?
    
    /// The Player Entity that is attached to the camera.
    let playerEntity = Player(target: .camera)

    /// The ground anchor entity that holds the tiles and other fixed game objects
//  var groundAncEntity: AnchorEntity!

    /// Switch that turns on and off the Minigames, cycling through them.
    @IBOutlet var minigameSwitch: UISwitch!
    /// Label to display minigame output.
    @IBOutlet var minigameLabel: UILabel!
  
    /// Minigame Controller Struct
    var minigameController: MinigameController!
    var subscribers: [Cancellable] = []
    
    
    /// Add the player entity and set the AR session to begin detecting the floor.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        name = self
        
        //Assign the ViewController class to act as the session's delegate (extension below)
        arView.session.delegate = self
        startTracking()
        
        minigameSwitch.isHidden = true
        minigameLabel.isHidden = true
        
        //self.arView.debugOptions = [.showStatistics]
        
    }
    
    private func startTracking() {
        //Define AR Configuration to detect horizontal surfaces
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        
        //Check if the device supports depth-based people occlusion and activate it if so
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            arConfig.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            print("This device does not support people occlusion")
        }
        
        //Run the tracking configuration (start detecting planes)
        self.arView.session.run(arConfig)
    }
    
}

//Extension of ViewController that acts as a delegate for the AR session
//Recieves updated scene info, can initiate actions based on scene-related events (i.e. anchor detection
extension ViewController: ARSessionDelegate {
        
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if self.boardState == .notMapped {
            if let validPlaneAnc = checkForValid(anchors: anchors) {
                self.initiateBoardLayout(surfaceAnchor: validPlaneAnc)
            }
        }
            
        else if self.boardState == .mapped {
            if let updatedAnchor = checkForUpdate(anchors: anchors) {
                self.tileGrid?.updateBoard(updatedAnc: updatedAnchor)
            }
        }        
    }
    
    //Checks a list of anchors for one that meets the valid surface requirements described by the GameBoard's EXTENT constants
    func checkForValid(anchors: [ARAnchor]) -> ARPlaneAnchor? {
        guard self.boardState == .notMapped else {return nil}
        for anc in anchors {
            if let planeAnc = anc as? ARPlaneAnchor {
                if isValidSurface(plane: planeAnc) {
                    return planeAnc
                }
            }
        }
        return nil
    }
    
    //Checks a list of anchors for one that matches the surface anchor of the tileGrid's surfaceAnchor
    func checkForUpdate(anchors: [ARAnchor]) -> ARPlaneAnchor? {
        guard self.boardState == .mapped else {return nil}
        for anc in anchors {
            if let planeAnc = anc as? ARPlaneAnchor {
                if planeAnc == self.tileGrid?.surfaceAnchor {
                    return planeAnc
                }
            }
        }
        return nil
    }
    
    func initiateBoardLayout(surfaceAnchor: ARPlaneAnchor) {
        guard self.boardState == .notMapped else {return}
        self.boardState = .mapping
        
        self.tileGrid = TileGrid(surfaceAnchor: surfaceAnchor)
        self.arView.scene.addAnchor(self.tileGrid!.gridEntity)
        self.boardState = .mapped
        
        self.addPbButton()
        self.addRbButton()
        self.startBoardPlacement()
        
        
//        setupMinigames(ground: self.tileGrid!.gridEntity)
    }
    
    func startBoardPlacement() {
        
        self.arView.scene.addAnchor(playerEntity)
        self.playerEntity.addCollision()
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 1.0)!, repeats: true) {timer in
            
            if self.boardState == .placed {
                timer.invalidate()
            }
                
            else if (self.playerEntity.onTile != nil) {
                self.tileGrid?.updateBoardOutline(centerTile: self.playerEntity.onTile!)
            }
            
        }
    }
    
    ///Transition from board placement --> game mode
    func moveToGameplay() {
        
        //Clean up the tile grid and board placement buttons
        self.arView.scene.removeAnchor(self.tileGrid!.gridEntity)
        self.activeButtons.forEach { (button) in
            button.removeFromSuperview()
        }
        
        //Instantiate a gameboard object with the current tile outline and add it to the scene
        self.gameBoard = GameBoard(tiles: self.tileGrid!.currentOutline, surfaceAnchor: self.tileGrid!.gridEntity.clone(recursive: false), center: (self.tileGrid?.centerTile!.coords)!)
        self.gameBoard?.addBoardToScene(arView: self.arView)
        
        // ERIN EDIT: Instantiate pet object in the middle of the gameboard and add it to the scene
        //func addBoardToScene(arView: ARView) {
            //arView.scene.addAnchor(self.board)
        //}
//        let virtualPetAnchor = ARAnchor(name: "VirtualPetNode", transform: float4x4(SIMD4<Float>(1, 0, 0, 0), SIMD4<Float>(0, 1, 0, 0), SIMD4<Float>(0, 0, 1, 0), SIMD4<Float>(0, -0.2, 0, 1)))
//        
//        sceneView.session.add(anchor: virtualPetAnchor)
    
        
        
        //Stop ARWorldTracking, as it is unnecessary from this point onwards (unless you desire further scene understanding for a specific minigame, in which case it can be re-activated)
        let newConfig = ARWorldTrackingConfiguration()
        self.arView.session.run(newConfig)
        
        //Set up the minigames
        setupMinigames(ground: self.gameBoard!.board.clone(recursive: false))
        //setupMinigames(ground: self.gameBoard!.board)
        self.addMgButton()
    }
    
    func setupMinigames(ground: AnchorEntity) {
        arView.scene.addAnchor(ground)
        ground.isEnabled = false
        
        //Instantiate the minigame controller
        minigameController = MinigameController(ground: ground, player: self.playerEntity)
        subscribers.append(minigameController.$score.sink(receiveValue: { (score) in
            self.minigameLabel.text = String(format:"Score: %0.0f", score)
        }))
        
        //Set up the floor entity, which will allow collision detection with the surface anchor during minigames
        Floor = Entity()
        let floorCollisionComp = CollisionComponent(shapes: [ShapeResource.generateBox(width: tileGrid!.surfaceAnchor.extent.x, height: 0.00, depth: tileGrid!.surfaceAnchor.extent.z)])
        let floorPhysicsComp = PhysicsBodyComponent(shapes: floorCollisionComp.shapes, density: 0.1, material: .default, mode: .static)
        Floor!.components.set([floorCollisionComp, floorPhysicsComp])
        
        minigameController.ground.addChild(Floor!)
        
        
        //Setup the Minigame. Switch is used for debugging purposes. In the product it should be a seamless transition.
        minigameLabel.isHidden = false
        minigameSwitch.isHidden = false
        minigameSwitch.setOn(false, animated: false)
        minigameSwitch.addTarget(self, action: #selector(minigameSwitchStateChanged), for: .valueChanged)
        addCollision()
        
        //subARview = arView
    }
        
    ///Here is code to load in the background model. Currently not recommended -- causes iPad to heat significantly and doesn't blend with scene well
    func addBackgroundModel() {
        
        subscribers.append(Entity.loadAsync(named: "Background").sink(receiveCompletion: { (loadCompletion) in
            // Handle Errors
            print(loadCompletion)
        }, receiveValue: { (backgroundModel) in
            // Create a background entity in which we apply our transforms depending on board placement and game settings.
            let background = Entity()
            background.addChild(backgroundModel)
            self.gameBoard!.board.addChild(background)
            //  Correction for the model to be centered. Other than centering the model, no other transform needs to be done on backgroundModel
            backgroundModel.transform.translation = SIMD3<Float>(0.0779, -0.01, 0.2977)
            background.transform.translation = (self.gameBoard?.center.translation)!
            background.transform.rotation = simd_quatf(angle: self.tileGrid?.rotated.angle ?? 0, axis: SIMD3<Float>(0, 1, 0))
            background.transform.scale = SIMD3(Tile.SCALE, Tile.SCALE, Tile.SCALE)
        }))
        
    }
    
}

// MARK: Board Generation Helper functions
extension ViewController {
    
    
    //Enumerator to represent current state of the game board
    enum BoardState {
        case notMapped
        case mapping
        case mapped
        case placed
    }
    
    //Checks if plane is valid surface, according to x and z extent
    func isValidSurface(plane: ARPlaneAnchor) -> Bool {
        guard plane.alignment == .horizontal else {return false}
        
        let minBoundary = min(plane.extent.x, plane.extent.z)
        let maxBoundary = max(plane.extent.x, plane.extent.z)
        
        let minExtent = min(GameBoard.EXTENT1, GameBoard.EXTENT2)
        let maxExtent = max(GameBoard.EXTENT1, GameBoard.EXTENT2)
        
        return minBoundary >= minExtent && maxBoundary >= maxExtent
    }
    
}


// MARK: Minigame Helper Functions
extension ViewController {
    /**
     Minigame switch logic.
     Switched on: a new game is created.
     Switched off: score is displayed and game is removed.
     */
    @objc func minigameSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            // TODO: Disable when done debugging Movement Game loading.
            self.startMinigame(gameType: .movement)
            // Remove Mg Button once movement game has started
            self.activeButtons.forEach { (button) in
                button.removeFromSuperview()
            }
        } else {
            minigameController.disableMinigame()
            self.minigameController.ground.isEnabled = false
            self.gameBoard?.board.isEnabled = true
        }
    }
    
    /**
     Adds the controller as a subview programmatically.
     */
    private func addViewController(controller: UIViewController) {
        // Add the View Controller as a subview programmatically.
        addChild(controller)
        // TODO Make a better frame depending on what UI elements are going to persist such that the Minigame Controller will not confict with the Persistent UI.
        print("Added child, creating frame.")
        let frame = self.view.frame.insetBy(dx: 0, dy: 100)
        print("Setting frame")
        controller.view.frame = frame
        print("Adding as subview")
        self.view.addSubview(controller.view)
        print("Setting Moved state")
        controller.didMove(toParent: self)
    }

}


// MARK: Switching between Board and Minigame
extension ViewController {
    func addCollision() {
        let scene = self.arView.scene
        self.subscribers.append(scene.subscribe(to: CollisionEvents.Began.self, on: self.playerEntity) { event in
            
// TODO: This line of code mirrors the line of code in the minigame switch. Unfortunately it still crashes when the minigame switch doesn't
//            self.startMinigame(gameType: .movement)

            print("Board Collision")
            guard let tile = event.entityB as? Tile else {
                return
            }
            guard let gameType = self.gameBoard?.gamesDict[tile] else {return}
            self.startMinigame(gameType: gameType)
            self.gameBoard?.removeGame(tile)
            print(gameType)
            print("End collision board")
        })
    }
    
    func startMinigame(gameType: Game) {
        self.gameBoard?.board.isEnabled = false
        self.minigameController.ground.isEnabled = true
        
        
        let controller = self.minigameController.enableMinigame(game: gameType)
        controller.arView = self.arView;
        print("Adding Controller")
        self.addViewController(controller: controller)
        print("Turning minigame switch on")
        self.minigameSwitch.setOn(true, animated: true)
        print("Switch is On")
    }
    
}

//extension ARView{
//
//    func setupGestures() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.addGestureRecognizer(tap)
//    }
//
//    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
//
//        guard let touchInView = sender?.location(in: self) else {
//            return
//        }
//
//        rayCastingMethod(point: touchInView)
//
//        //to find whether an entity exists at the point of contact
//        let entities = self.entities(at: touchInView)
//    }
//
//    func rayCastingMethod(point: CGPoint) {
////        guard let coordinator = self.session.delegate as? ARViewCoordinator else{ print("GOOD NIGHT"); return }
//
//        guard let raycastQuery = self.makeRaycastQuery(from: point,
//                                                       allowing: .existingPlaneInfinite,
//                                                       alignment: .horizontal) else {
//
//                                                        print("failed first")
//                                                        return
//        }
//
//        guard let result = self.session.raycast(raycastQuery).first else {
//            print("failed")
//            return
//        }
//
//        let transformation = Transform(matrix: result.worldTransform)
//        let box = CustomBox(color: .yellow)
//        self.installGestures(.all, for: box)
//        box.generateCollisionShapes(recursive: true)
//
//        let mesh = MeshResource.generateText(
//            "\(coordinator.overlayText)",
//            extrusionDepth: 0.1,
//            font: .systemFont(ofSize: 2),
//            containerFrame: .zero,
//            alignment: .left,
//            lineBreakMode: .byTruncatingTail)
//
//        let material = SimpleMaterial(color: .red, isMetallic: false)
//        let entity = ModelEntity(mesh: mesh, materials: [material])
//        entity.scale = SIMD3<Float>(0.03, 0.03, 0.1)
//
//        box.addChild(entity)
//        box.transform = transformation
//
//        entity.setPosition(SIMD3<Float>(0, 0.05, 0), relativeTo: box)
//
//        let raycastAnchor = AnchorEntity(raycastResult: result)
//        raycastAnchor.addChild(box)
//        self.scene.addAnchor(raycastAnchor)
//    }
//}
