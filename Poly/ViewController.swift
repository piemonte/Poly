//
//  ViewController.swift
//  Poly
//
//  Copyright (c) 2018-present patrick piemonte (http://patrickpiemonte.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import SceneKit
import ModelIO
import ARKit

public class ViewController: UIViewController {

    // MARK: - properties
    
    // MARK: - ivars
    
    internal var _arConfig: ARConfiguration?
    internal var _arView: ARSCNView?
    internal var _tapGestureRecognizer: UITapGestureRecognizer?
    
    internal var _exampleNode: SCNNode?
    
    // MARK: - object lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
    
    // MARK: - view lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // preview
        self._arView = ARSCNView(frame: self.view.bounds)
        if let arView = self._arView {
            arView.delegate = self
            arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
            arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            arView.backgroundColor = UIColor.black
            arView.autoenablesDefaultLighting = true
            arView.automaticallyUpdatesLighting = true
            arView.scene = SCNScene()
            arView.isPlaying = true
            arView.loops = true
            self.view.addSubview(arView)
        }
        
        // gestures
        self._tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_ :)))
        if let tapGestureRecognizer = self._tapGestureRecognizer {
            tapGestureRecognizer.numberOfTapsRequired = 1
            self._arView?.addGestureRecognizer(tapGestureRecognizer)
        }
        
        // Poly

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        self._arView?.session.run(config, options: [.resetTracking])
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self._arView?.session.pause()
    }

}

// MARK: -  status bar

extension ViewController {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
}

// MARK: - UIGestureRecognizer

extension ViewController {
    
    @objc internal func handleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if let arView = self._arView {
            let point = gestureRecognizer.location(in: arView)
            let hitTest = arView.hitTest(point, types: [.existingPlane, .existingPlaneUsingExtent, .estimatedHorizontalPlane])
            guard let hitPoint = hitTest.first else {
                return
            }
            
            let nodePostion = SCNVector3(hitPoint.worldTransform.columns.3.x,
                                         hitPoint.worldTransform.columns.3.y,
                                         hitPoint.worldTransform.columns.3.z)
            self._exampleNode?.position = nodePostion
            
            if let node = self._exampleNode,
                node.parent == nil {
                arView.scene.rootNode.addChildNode(node)
            }
        }
    }
    
}
