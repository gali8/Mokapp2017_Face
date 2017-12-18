//
//  SCNNodeExtension.swift
//  Mokapp2017
//
//  Created by Daniele on 11/11/17.
//  Copyright © 2017 nexor. All rights reserved.
//

import UIKit
import ARKit

extension SCNNode {
    
    class func createPlaneNode(position: SCNVector3, size: CGSize, color: UIColor = UIColor.blue.withAlphaComponent(0.4)) -> SCNNode {
        let plane = SCNPlane(width: size.width, height: size.height)
        
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = color
        plane.materials = [planeMaterial]
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = position
        //planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        return planeNode
    }
    
    class func createPlaneBoxNode(position: SCNVector3, size: CGSize, color: UIColor = UIColor.blue.withAlphaComponent(0.4)) -> SCNNode {
        let plane = SCNBox(width: size.width, height: 0.001, length: size.height, chamferRadius: 0)
        
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = color
        plane.materials = [planeMaterial]
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = position
        
        return planeNode
    }
    
    class func updatePlaneNode(node: SCNNode, center: vector_float3, extent: vector_float3) {
        let geometry = node.geometry as? SCNPlane
        
        geometry?.width = CGFloat(extent.x)
        geometry?.height = CGFloat(extent.z)
        node.position = SCNVector3Make(center.x, 0, center.z)
    }
    
    class func setPhysicsToNode(node: SCNNode, type: SCNPhysicsBodyType = .static, mass: CGFloat? = nil, restituition: CGFloat? = nil, friction: CGFloat? = nil, geometry: SCNGeometry, isAffectedByGravity: Bool = false) {
        
        let physicShape = SCNPhysicsShape(geometry: geometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: type, shape: physicShape)
        physicsBody.mass = mass ?? physicsBody.mass
        physicsBody.restitution = restituition ?? physicsBody.restitution
        physicsBody.friction = friction ?? physicsBody.friction
        physicsBody.isAffectedByGravity = isAffectedByGravity
        
        node.physicsBody = physicsBody
    }
    
    class func removeChildren(inNode node: SCNNode) {
        for node in node.childNodes {
            node.removeFromParentNode()
        }
    }
    
    class func createSphereNode(radius: CGFloat) -> SCNNode {
        let sphere = SCNSphere(radius:radius)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        return SCNNode(geometry: sphere)
    }
    
   class func createLineNode(fromNode: SCNNode, toNode: SCNNode) -> SCNNode {
        let line = lineFrom(vector: fromNode.position, toVector: toNode.position)
        let lineNode = SCNNode(geometry: line)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.red
        line.materials = [planeMaterial]
        return lineNode
    }
    
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    func moveToPosition(position: SCNVector3, duration: TimeInterval = 0.3) {
        let action = SCNAction.move(to: position, duration: duration)
        action.timingMode = .easeOut
        self.runAction(action)
    }
}
