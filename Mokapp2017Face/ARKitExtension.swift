//
//  ARKitExtension.swift
//  TestARKit
//
//  Created by Daniele on 25/09/17.
//  Copyright © 2017 nexor. All rights reserved.
//

import UIKit
import ARKit

struct CollisionTypes : OptionSet {
    let rawValue: Int
    
    static let bottom  = CollisionTypes(rawValue: 1 << 0)
    static let shape = CollisionTypes(rawValue: 1 << 1)
}

extension FaceViewController: ARSCNViewDelegate {
    
    func runSession() {
        
        guard ARFaceTrackingConfiguration.isSupported == true else {
            print("ARFaceTrackingConfiguration not supported")
            return
        }
        
        // Set the view's delegate
        scnView.delegate = self
        
        self.resetTracking()
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        self.scnView.antialiasingMode = .multisampling4X
        self.scnView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func reset() {
        if let vcId = self.restorationIdentifier, let vc = self.storyboard?.instantiateViewController(withIdentifier: vcId), let kw = UIApplication.shared.keyWindow, let rvc = kw.rootViewController {
            vc.view.frame = rvc.view.frame
            vc.view.layoutIfNeeded()
            
            UIView.transition(with: kw, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                kw.rootViewController = vc
            }, completion: nil)
        }
        else {
            self.scnView.debugOptions = []
            self.scnView.scene.rootNode.removeAllAnimations()
            self.scnView.scene.rootNode.removeAllParticleSystems()
            self.scnView.scene.rootNode.removeAllAudioPlayers()
//            for node in self.scnView.scene.rootNode.childNodes {
//                node.removeAllAnimations()
//                node.removeAllParticleSystems()
//                node.removeAllAudioPlayers()
//                node.removeFromParentNode()
//            }
        }
    }
    
    //MARK: - ARSCNViewDelegate
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            switch anchor {
            case let a where a is ARPlaneAnchor:
                break
            case let a where a is ARFaceAnchor:
                //#if DEBUG
                    let faceAnchor = a as! ARFaceAnchor
                    self.faceNode = node
                    self.loadRightNode()
                //#endif
                break
            default:
                break
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            
            //self.scnView.hitTest(sel., types: ARHitTestResult.ResultType.)
            
            let key = anchor.identifier.uuidString
            
            switch anchor {
            case let a where a is ARPlaneAnchor:
                let planeAnchor = a as! ARPlaneAnchor
                break
            case let a where a is ARFaceAnchor:
                let faceAnchor = anchor as! ARFaceAnchor
                self.updateRightNode(anchor: faceAnchor)
                break
            default:
                break
            }
        }
    }
    
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            
            let key = anchor.identifier.uuidString
            
            switch anchor {
            case let a where a is ARPlaneAnchor:
                break
            case let a where a is ARFaceAnchor:
                SCNNode.removeChildren(inNode: node)
                break
            default:
                break
            }
        }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("error \(error)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
    
    func updateTrackingInfo() -> String? {
        guard let frame = self.scnView.session.currentFrame else {
            return nil
        }
        
        switch frame.camera.trackingState {
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "Limited tracking: excessive motion"
            case .insufficientFeatures:
                return "Limited tracking: insufficient details"
            case .initializing:
                return "....initializing"
            }
        default:
           break
        }
        
        guard let lightEstimate = frame.lightEstimate?.ambientIntensity else {
            return nil
        }
        
        if lightEstimate < 60 {
            return "Limited tracking: Too dark"
        }
        
        return nil
    }
    
}


let bottomWorldPlaneNodeName: String = "BottomWorldPlaneNode"

extension FaceViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        DispatchQueue.main.async {
//            if contact.nodeA.name == bottomWorldPlaneNodeName {
//                contact.nodeB.removeFromParentNode()
//                return
//            }
//            if contact.nodeB.name == bottomWorldPlaneNodeName {
//                contact.nodeA.removeFromParentNode()
//                return
//            }
//
//            self.spaceInvadersPhysicsWorld(world, didBegin: contact)
//        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
    }
    
}
