//
//  MovementViewController.swift
//  ARrehab
//
//  Created by Eric Wang on 5/2/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit
import Combine
import MultiProgressView
import RealityKit
import ARKit

/**
 Movement Minigame ViewController.
 */
class MovementGameViewController : MinigameViewController {
    
    /// Flat Coaching Image
    @IBOutlet var coachImageView: UIImageView!
    
    /// list of TracePoints that make up this target.
    var collectPointCloud : [CollectPoint] = []
    
    //List of collection targets to try and pick up
    var collectTargets : [CollectTargetType] = [.colorful, .tealMarble, .blueMarble, .yellowMarble, .orangeMarble]
    /// Coaching state
    
    var hitEntity : CollectPoint!
    var targetCheck : CollectTargetType!
    
    //override var arView: ARView!
//    func loadInInstance(ViewController: ViewController) {
//        self.arView = ViewController.arView
//    }
    //var subarview : subARview!
    
//    // Add a gesture recognizer
//    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//    self.addGestureRecognizer(tapGestureRecognizer)
//    tapGestureRecognizer.cancelsTouchesInView = false
    
//
    func generateCollectTargets() {
        var models : [CollectTargetType : ModelComponent] = [:]
        
        collectTargets.forEach { (collectTargetType) in
            do {
                models.updateValue((try Entity.loadModel(named: collectTargetType.modelName).model!), forKey: collectTargetType)
            } catch {
                models.updateValue((ModelComponent(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .purple, isMetallic: false)])), forKey: CollectTargetType.blueMarble)
            }
        }
//        One of the simplest way is to add the vase as a table's child node since you don't need to update vase position whenever the table moves:
//        tableNode.addChildNode(vaseNode)
//        Set position of the vase to the middle of the table face. You have to calculate y or set it manually:
//        vaseNode.position = SCNVector3(0, y, 0)
//        The following code is to calculate y:
//        let tableHeight = tableNode.boundingBox.max.y - tableNode.boundingBox.min.y
//        let vaseHeight = vaseNode.boundingBox.max.y - vaseNode.boundingBox.min.y
//        Now you can set the vase as it is on the table face:
//        vaseNode.position = SCNVector3(0, (tableHeight + vaseHeight) / 2, 0)
        //let Floorwidth = Floor.boundingBox
        //var posx = Floor?.position(relativeTo: <#T##Entity?#>)
        for _ in 1 ... 5 {
            let (targetType, model) = models.randomElement()!
            let posMin = targetType.minPosition
            let posMax = targetType.maxPosition
            let point : CollectPoint = CollectPoint(model: model, translation: SIMD3<Float>(Float.random(in: posMin[0] ... posMax[0]), Float.random(in: posMin[1] ... posMax[1]), Float.random(in:posMin[2] ... posMax[2])), targetType: targetType)
            //point.position(relativeTo: Floor)
            //setPosition(point position: SIMD3<Float>, relativeTo referenceEntity: Entity?)
            point.setPosition((SIMD3<Float>(Float.random(in: -1 ... 1), 0, Float.random(in: -1 ... 1))) , relativeTo: Floor)
//            point.collision?.filter = CollisionFilter(group: self.pointCollisionGroup, mask: self.laserCollisionGroup)
            point.scale = SIMD3<Float>(3.0, 3.0, 3.0)
            print(point.position)
            collectPointCloud.append(point)
            // Make it interactable
            self.arView.installGestures(for: point)
            // Place anchor and marble in scene
            self.arView.scene.addAnchor(point)
        }
    }
    
//    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
//        print("Tapped!!")
//        guard let touchInView = sender?.location(in: self.arView) else { return
//        }
//        print("pre hit entity")
//        print(self.arView.entity(at: touchInView))
//        guard let hitEntity = self.arView.entity(at: touchInView) else { return }
//        print(hitEntity.position)
//
//    }
    
    @objc func handleTap(sender:UITapGestureRecognizer) {
        let tappedView = sender.view as! ARView
        //print(sender.view)
        let touchLocation = sender.location(in: tappedView)
        let hitTestResult = tappedView.hitTest(touchLocation)
        print("----------------------------------------------------------------------")
        print("RESULTSSSSS")
        //print(hitTestResult)

        if !hitTestResult.isEmpty {
            // add something to scene
            // e.g self.sceneView.scene.rootNode.addChildNode(yourNode!)
            print("----------------------------------------------------------------------")
            for item in hitTestResult{
                if item.entity is CollectPoint {
//                    print ("BOOYAH")
                    //make marble glow
                    //move dragon there
                    //show coaching image
                    // After user squats, show dragon sqatting
                    // Make marble disappear (with a flourish)
                    // Check number of marbles left
                    //  if 0, show game over!
                }
//                let hitEntity = item.entity is CollectTargetType // entity
//                guard let _ = _ else {}
//                //let targetCheck = hitEntity.targetType
//                print(hitEntity)
                else {
//                    print("")
                    //move dragon there
                }
            }
//            let result = hitTestResult.first!
//            let name = result.entity.name
//            let geometry = result.entity.position
            //print("Tapped \(String(describing: name)) with geometry \(String(describing: geometry))")
        }
    }

//    // ARview
//    let
//    @IBOutlet var arView : ARview!
    /// Progress subscribers
    var subscriberss: [Cancellable] = []
//    let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [.2, .2])
//    arView.addAnchor(anchor)
//

    private let backgroundView: UIView = {
        let view = PassThroughView()
        return view
    }()

    private lazy var progressView: MultiProgressView = {
        let progress = MultiProgressView()
        progress.trackBackgroundColor = UIColor.white
        progress.lineCap = .round
        progress.cornerRadius = progressViewHeight / 4
        return progress
    }()
//
//    private let stackView: UIStackView = {
//        let sv = UIStackView()
//        sv.distribution = .equalSpacing
//        sv.alignment = .center
//        return sv
//    }()

    private let padding: CGFloat = 15
    private let progressViewHeight: CGFloat = 20
    private let progressViewWidth: CGFloat = 500

    override func viewDidLoad() {
        //print("Loading SuperView")
        //super.viewDidLoad()
        //print("Super View did load. Adding custom elements")
        view.addSubview(backgroundView)
        backgroundView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                left: view.safeAreaLayoutGuide.leftAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              //right: view.safeAreaLayoutGuide.rightAnchor,
                              paddingTop: 50,
                              paddingBottom: 50,
                              width: progressViewWidth
                            )
        backgroundView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        //setupProgressBar()
//        setupStackView()
        addMinigameSubscriber()
        //print(POTATO)
        print("Complete viewDidLoad")
        generateCollectTargets()
        //arView.environment.lighting(
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
//    private func setupProgressBar() {
//        backgroundView.addSubview(progressView)
//        progressView.anchor(top: backgroundView.topAnchor,
//                            left: backgroundView.leftAnchor,
//                            //right: backgroundView.rightAnchor,
//                            paddingTop: padding,
//                            paddingLeft: padding,
//                            paddingRight: padding,
//                            width: progressViewWidth,
//                            height: progressViewHeight)
//        progressView.dataSource = self
//        progressView.delegate = self
//        //backgroundView.translatesAutoresizingMaskIntoConstraints = true
//    }
//
//    private func setupStackView() {
//        backgroundView.addSubview(stackView)
//        stackView.anchor(top: progressView.bottomAnchor,
//                         left: backgroundView.leftAnchor,
//                         bottom: backgroundView.bottomAnchor,
//                         right: backgroundView.rightAnchor,
//                         paddingTop: padding,
//                         paddingLeft: padding,
//                         paddingBottom: padding,
//                         paddingRight: padding)
//
//        // TODO FIXME
////        for type in (minigame as! MovementGame).targets {
//////            if type != .unknown {
////                stackView.addArrangedSubview(TraceStackView(traceTargetType: type))
//////            }
////        }
//        stackView.addArrangedSubview(UIView())
//    }
//
//    private func animateProgress(progress: [Float]) {
//        UIView.animate(withDuration: 0.4,
//                       delay: 0,
//                       usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0,
//                       options: .curveLinear,
//                       animations: {
//                        self.progressView.setProgress(section: 0, to: progress[1])
//        })
////        dataUsedLabel.text = "56.5 GB of 64 GB Used"
//    }

//    private func resetProgress() {
//        UIView.animate(withDuration: 0.1) {
//            self.progressView.resetProgress()
//        }
////        dataUsedLabel.text = "0 GB of 64 GB Used"
//    }

    override func attachMinigame(minigame: Minigame) {
        super.attachMinigame(minigame: minigame)
        
        if self.isViewLoaded {
            // TODO cancel the previous score subscription
            addMinigameSubscriber()
//            setupStackView()
        }
    }

    func addMinigameSubscriber() {
        guard minigame != nil else {
            return
        }

//        subscribers.append(minigame!.$progress.sink(receiveValue: { (progress) in
//            self.animateProgress(progress: progress)
//        }))
        subscriberss.append(minigame().$coachingState.sink(receiveValue: { (state) in
            // TODO
            self.coachImageView.image = state.image
        }))
    }
}

// MARK: - UtilityFunctions
extension MovementGameViewController {
    func minigame() -> MovementGame {
        return self.minigame as! MovementGame
    }
}

// MARK: - MultiProgressViewDataSource

//extension MovementGameViewController: MultiProgressViewDataSource {
//    public func numberOfSections(in progressBar: MultiProgressView) -> Int {
//        return 1
//    }
//
//    public func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
//        let bar = ProgressViewSection()
//        // FIXME
//        bar.backgroundColor = .blue
//        return bar
//    }
//}
//
//// MARK: - MultiProgressViewDelegate
//
//extension MovementGameViewController: MultiProgressViewDelegate {
//
//    func progressView(_ progressView: MultiProgressView, didTapSectionAt index: Int) {
//        print("Tapped section \(index)")
//    }
//}


