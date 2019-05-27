//
//  FaseShapes.swift
//  Mokapp2017Face
//
//  Created by Daniele on 23/11/17.
//  Copyright © 2017 nexor. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

protocol VirtualSCNReferenceNode {
    func update(withFaceAnchor faceAnchor: ARFaceAnchor)
}

class BlendShapeNode: SCNReferenceNode, VirtualSCNReferenceNode {
    
    private lazy var leftEarring = childNode(withName: "earring", recursively: true)!
    private lazy var eyebrowLeft = childNode(withName: "eyebrowLeft", recursively: true)!
    private lazy var eyeLeft = childNode(withName: "eyeLeft", recursively: true)!
    private lazy var eyeLeftPupil = childNode(withName: "eyeLeftPupil", recursively: true)!
    private lazy var eyebrowRight = childNode(withName: "eyebrowRight", recursively: true)!
    private lazy var eyeRight = childNode(withName: "eyeRight", recursively: true)!
    private lazy var eyeRightPupil = childNode(withName: "eyeRightPupil", recursively: true)!
    lazy var mouth = childNode(withName: "mouth", recursively: true)!
    private lazy var nose = childNode(withName: "nose", recursively: true)!
    private lazy var tongue = childNode(withName: "tongue", recursively: true)!
    private lazy var tongueAnimating: Bool = false
    
    private var originalLeftEarringPosition: Float = 0
    private var originalEyebrowLeftPosition: Float = 0
    private var originalEyebrowRightPosition: Float = 0
    
    private var originalEyeLeftPupilPosition: Float = 0
    private var originalEyeRightPupilPosition: Float = 0
    
    private var originalMouthPosition: Float = 0
    
    private var originalNosePosition: Float = 0
    
    private var originalTonguePosition: Float = 0
    
    init() {
        guard let url = Bundle.main.url(forResource: "accessory", withExtension: "scn", subdirectory: "blendShape.scnassets")
            else { fatalError("missing expected bundle resource") }
        super.init(url: url)!
        self.load()
        originalLeftEarringPosition = leftEarring.position.y
        originalEyebrowLeftPosition = eyebrowLeft.position.y
        originalEyebrowRightPosition = eyebrowRight.position.y
        originalEyeLeftPupilPosition = eyeLeftPupil.position.x
        originalEyeRightPupilPosition = eyeRightPupil.position.x
        originalMouthPosition = mouth.position.y
        originalNosePosition = nose.position.x
        originalTonguePosition = tongue.position.y
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var blendShapes: [ARFaceAnchor.BlendShapeLocation: Any] = [:] {
        didSet {
            guard
                let browRight = blendShapes[.browOuterUpRight] as? Float,
                let browLeft = blendShapes[.browOuterUpLeft] as? Float,
                let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
                let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
                let eyeLookInLeft = blendShapes[.eyeLookInLeft] as? Float,
                let eyeLookOutLeft = blendShapes[.eyeLookOutLeft] as? Float,
                let eyeLookInRight = blendShapes[.eyeLookInRight] as? Float,
                let eyeLookOutRight = blendShapes[.eyeLookOutRight] as? Float,
                let jawOpen = blendShapes[.jawOpen] as? Float,
                let mouthClose = blendShapes[.mouthClose] as? Float,
                let mouthSmileLeft = blendShapes[.mouthSmileLeft] as? Float,
                let mouthSmileRight = blendShapes[.mouthSmileRight] as? Float,
                let noseSneerLeft = blendShapes[.noseSneerLeft] as? Float,
                let noseSneerRight = blendShapes[.noseSneerRight] as? Float,
                let tongueOut = blendShapes[.tongueOut] as? Float
                else { return }
            //leftEarring.scale.z = 1 - eyeBlinkLeft
            
            let eyebrowRightHeight = eyebrowRight.boundingBox.max.y - eyebrowRight.boundingBox.min.y
            eyebrowRight.position.y = originalEyebrowRightPosition + (eyebrowRightHeight / 2 * (browRight))
            
            let eyebrowLeftHeight = eyebrowLeft.boundingBox.max.y - eyebrowLeft.boundingBox.min.y
            eyebrowLeft.position.y = originalEyebrowLeftPosition + (eyebrowLeftHeight / 2 * (browLeft))
            
            eyeLeft.scale.y = 1 - eyeBlinkLeft
            eyeRight.scale.y = 1 - eyeBlinkRight
            
            let eyeRightPupilWidth = eyeRightPupil.boundingBox.max.x - eyeRightPupil.boundingBox.min.x
            if eyeLookInRight > eyeLookOutRight {
                eyeRightPupil.position.x = originalEyeRightPupilPosition + (eyeRightPupilWidth * eyeLookInRight)
            }
            else {
                eyeRightPupil.position.x = originalEyeRightPupilPosition - (eyeRightPupilWidth * eyeLookOutRight)
            }
            
            let eyeLeftPupilWidth = eyeLeftPupil.boundingBox.max.x - eyeLeftPupil.boundingBox.min.x
            if eyeLookInLeft > eyeLookOutLeft {
                eyeLeftPupil.position.x = originalEyeLeftPupilPosition - (eyeLeftPupilWidth * eyeLookInLeft * 2)
            }
            else {
                eyeLeftPupil.position.x = originalEyeLeftPupilPosition + (eyeLeftPupilWidth * eyeLookOutLeft * 2)
            }
            
            mouth.scale.y = 0.40 + jawOpen
            
            mouth.scale.x = 0.7 - mouthClose + (max(mouthSmileLeft, mouthSmileRight)/2)
            
//            let noseWidth = nose.boundingBox.max.x - nose.boundingBox.min.x
//            if max(noseSneerLeft, noseSneerRight) > 0.3 {
//                if noseSneerLeft > noseSneerRight {
//                    nose.position.x = originalNosePosition - (noseWidth * noseSneerLeft)
//                }
//                else {
//                    nose.position.x = originalNosePosition + (noseWidth * noseSneerRight)
//                }
//            }
            
            
            if tongueOut > 0.3 {
                if tongue.scale.y < 3 {
                    tongue.position.y -= tongueOut / 100
                    tongue.scale.y -= tongueOut
                }
            }
            else {
                tongue.position.y = originalTonguePosition
                tongue.scale.y = 1
            }
            
            
//            if tongueOut > 0.5, self.tongueAnimating == false {
//
//                self.tongueAnimating = true
//
//                let action = SCNAction.rotateBy(x: 0, y: 0, z: .pi, duration: 0.3)
//                tongue.runAction(action, completionHandler: {
//                    self.tongueAnimating = false
//                })
//            }
            
            //jawNode.position.y = originalJawY - jawHeight * jawOpen
        }
    }
    
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        blendShapes = faceAnchor.blendShapes
    }
}
