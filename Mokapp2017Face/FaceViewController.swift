//
//  FaceViewController.swift
//  Mokapp2017
//
//  Created by Daniele on 07/11/17.
//  Copyright © 2017 nexor. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import ARKit

enum FaceDemoType {
    case start
    case mask
    case blendShapes
    case particle
    case all
}

class FaceViewController: UIViewController {
    
    @IBOutlet weak var scnView: ARSCNView!
    
    var faceDemoType: FaceDemoType = .start {
        didSet {
            if let fn = faceNode {
                for n in fn.childNodes {
                    n.removeFromParentNode()
                }
            }
            self.resetTracking()
        }
    }
    
    var faceDemoTypeGeometry: SCNGeometry? {
        get {
            switch faceDemoType {
            case .mask:
                let faceGeometry = ARSCNFaceGeometry(device: self.scnView.device!)
                let material = faceGeometry?.firstMaterial
                material?.diffuse.contents = UIColor.green //spumeggiante!
                material?.lightingModel = .physicallyBased
                return faceGeometry
            case .blendShapes,
            .particle,
            .all:
                let faceGeometry = ARSCNFaceGeometry(device: self.scnView.device!)
                let material = faceGeometry?.firstMaterial
                material?.diffuse.contents = UIColor.clear //spumeggiante!
                return faceGeometry
            default:
                return nil
            }
        }
    }
    
    var faceDemoTypeNode: SCNNode? {
        get {
            switch faceDemoType {
            case .mask:
                self.virtualReferenceNode = nil
                return nil
            case .blendShapes,
            .particle,
            .all:
                let node = BlendShapeNode()
                self.virtualReferenceNode = node
                return node
            default:
                return nil
            }
        }
    }

    
    var faceNode: SCNNode?
    var virtualReferenceNode: VirtualSCNReferenceNode?
    
    var mouthPlayer : AVAudioPlayer?
    var mouthOpen : Bool = false
    lazy var mouthSoundAsset : NSDataAsset? = {
        return NSDataAsset(name: "MouthSound")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.prepareMouthAudio()
        self.runSession()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.scnView.session.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.runSession()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {        
        // check what nodes are tapped
        let touchLocation = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(touchLocation, options: [:])
        
        // check that we clicked on at least one object
        if let result = hitResults.first {
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
            
            //add object to exact tapped location
            /*
             let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
             let newLampNode = lampNode?.clone()
             if let newLampNode = newLampNode {
             newLampNode.position = newLocation
             sceneView.scene.rootNode.addChildNode(newLampNode)
             }*/
        }
    }

    @IBAction func onMask(_ sender: Any) {
        faceDemoType = .mask
    }
    @IBAction func onBlendShapes(_ sender: Any) {
        faceDemoType = .blendShapes
    }
    @IBAction func onParticle(_ sender: Any) {
        faceDemoType = .particle
    }
    @IBAction func onAll(_ sender: Any) {
        faceDemoType = .all
    }
    
    @IBAction func onReset(_ sender: Any) {
        reset()
    }
    
        
    func loadRightNode() {
        switch faceDemoType {
        case .start:
            break
        case .mask:
            self.faceNode?.geometry = faceDemoTypeGeometry
            break
        case .blendShapes:
            self.faceNode?.geometry = faceDemoTypeGeometry;
            self.faceNode?.addChildNode(faceDemoTypeNode!)
            break
        case .particle:
            self.faceNode?.geometry = faceDemoTypeGeometry;
            self.faceNode?.addChildNode(faceDemoTypeNode!)
            guard let virtualnode = self.virtualReferenceNode as? BlendShapeNode else {
                break
            }
            let particle = SCNParticleSystem(named: "Fire.scnp", inDirectory: nil)!
            particle.emitterShape = virtualnode.mouth.geometry
            virtualnode.mouth.addParticleSystem(particle)
            break
        case .all:
            self.faceNode?.geometry = faceDemoTypeGeometry;
            self.faceNode?.addChildNode(faceDemoTypeNode!)
            guard let virtualnode = self.virtualReferenceNode as? BlendShapeNode else {
                break
            }
            virtualnode.mouth.isHidden = true
            break
        }
    }
    
    func prepareMouthAudio() {
        guard let mouthSound = mouthSoundAsset else { return }
        do {
            mouthPlayer = try AVAudioPlayer(data:mouthSound.data, fileTypeHint:"m4a")
            mouthPlayer?.prepareToPlay()
        } catch {
            
        }
    }
    func handlerMouthOpen() {
        guard !mouthOpen else { return }
        mouthOpen = true
        mouthPlayer?.play()
    }
    
    func handlerMouthClosed() {
        guard mouthOpen else { return }
        mouthOpen = false
        mouthPlayer?.pause()
    }
    
    func updateRightNode(anchor: ARFaceAnchor) {
        if let faceGeometry = self.faceNode?.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: anchor.geometry)
        }
        switch faceDemoType {
        case
        .start,
        .mask:
            break
        case .blendShapes:
            virtualReferenceNode?.update(withFaceAnchor: anchor)
            break
        case .particle:
            virtualReferenceNode?.update(withFaceAnchor: anchor)
            break
        case .all:
            virtualReferenceNode?.update(withFaceAnchor: anchor)
            if let mouthOpenness = anchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthClose]?.floatValue {
                if mouthOpenness > 0.025 {
                    handlerMouthOpen()
                } else {
                    handlerMouthClosed()
                }
            }
            break
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
