//
//  BLMapListController.swift
//  https://github.com/batkov/BLActionController
//
// Copyright (c) 2017 Hariton Batkov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import BLListDataSource
import BLListViewController
import MapKit
import FBAnnotationClustering

public protocol BLMapObject : MKAnnotation {
    func isAnnotationAvailable() -> Bool
}

open class BLMapListController : UIViewController, MKMapViewDelegate, UIViewControllerTransitioningDelegate {
    open var dataSource : BLListDataSource?
    open var listBlock : ((BLListDataSource)->(UIViewController))?
    
    let clusteringManager = FBClusteringManager()
    
    public static let kBLActionControllerMapStoryboardName = "Map"
    public static let kBLActionControllerMapNavIdentifier = "nav_map"
    public static let kBLActionControllerMapIdentifier = "map"
    public static let kBLActionControllerMapListIdentifier = "list"
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var seeListButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    static func navigationControllerWith(dataSource : BLListDataSource) -> UINavigationController {
        precondition(BLActionControllerBundle != nil)
        
        let storyboard = UIStoryboard(name: kBLActionControllerMapStoryboardName,
                                      bundle: BLActionControllerBundle)
        let navController = storyboard.instantiateViewController(withIdentifier: kBLActionControllerMapNavIdentifier) as! UINavigationController
        let mapController = navController.viewControllers.first as! BLMapListController
        mapController.dataSource = dataSource
        return navController
    }
    
    static func mapControllerWith(dataSource : BLListDataSource) -> BLMapListController {
        precondition(BLActionControllerBundle != nil)
        
        let storyboard = UIStoryboard(name: kBLActionControllerMapStoryboardName,
                                      bundle: BLActionControllerBundle)
        let mapController = storyboard.instantiateViewController(withIdentifier: kBLActionControllerMapIdentifier) as! BLMapListController
        mapController.dataSource = dataSource
        return mapController
    }
    
    func reloadMap() {
        guard let dataSource = dataSource else {
            return
        }
        let blockPresented = listBlock != nil
        let alpha = CGFloat(blockPresented && dataSource.hasContent() ? 1 : 0)
        separatorView.alpha = alpha
        seeListButton.alpha = alpha
        mapView(mapView, regionDidChangeAnimated: false)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        precondition(dataSource != nil)
        dataSource!.itemsChangedBlock = { [weak self] (items) in
            guard let dataStructure = self?.dataSource?.dataStructure else {
                return
            }
            var annotations = [MKAnnotation]()
            dataStructure.enumerateObjects({ (object, indexPath, stop) in
                guard let mapObject = object as? BLMapObject else {
                    print("BLMapListController got object \(object) that does not conform to BLMapObject");
                    return
                }
                if mapObject.isAnnotationAvailable() {
                    annotations.append(mapObject)
                }
            })
            DispatchQueue.main.async {
                self?.clusteringManager.setAnnotations(annotations)
                self?.reloadMap()
            }
        }
        if dataSource?.state == .init {
            dataSource?.startContentLoading()
        } else {
            dataSource?.refreshContentIfPossible()
        }
        reloadMap()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func seeListTapped(_ sender: Any) {
        precondition(dataSource != nil)
        guard let listBlock = listBlock else {
            print("Provide listBlock to show list")
            return
        }
        let destination = listBlock(dataSource!)
        
        var probablyList = destination
        
        var push = true
        if let navigation = probablyList as? UINavigationController {
            if let first = navigation.viewControllers.first {
                probablyList = first
            }
            push = false
        }
        
        if let list = probablyList as? BLListViewController {
            if list.dataSource == nil {
                list.dataSource = dataSource!
            }
        }
        if destination.transitioningDelegate == nil {
            destination.transitioningDelegate = self
        }
        if let navigation = navigationController {
            if push {
                navigation.pushViewController(destination, animated: true)
            } else {
                navigation.present(destination, animated: true, completion: nil)
            }
        } else {
            present(destination, animated: true, completion: nil)
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let bounds = mapView.bounds
        let visibleMapRect = mapView.visibleMapRect
        OperationQueue().addOperation { [weak self] in
            let scale = Double(bounds.size.width) / Double(visibleMapRect.size.width)
            let annotations = self?.clusteringManager.clusteredAnnotations(within: visibleMapRect,
                                                                           withZoomScale: scale)
            
            self?.clusteringManager.displayAnnotations(annotations, on: mapView)
        }
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BLFromBottomAnimationController(false)
    }
    

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BLFromBottomAnimationController(true)
    }
    
}

class BLFromBottomAnimationController : NSObject, UIViewControllerAnimatedTransitioning {
    var reverse = false
    var length = 0.5
    
    init(_ reverse : Bool) {
        self.reverse = reverse
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return length
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let inView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)
        let fromViewOp = fromVC?.view
        let toVC = transitionContext.viewController(forKey: .to)
        let toViewOp = toVC?.view
        
        guard let fromView = fromViewOp, let toView = toViewOp  else {
            transitionContext.completeTransition(false)
            return
        }
        
        let frame = toView.frame;
        
        if reverse {
            inView.insertSubview(toView, belowSubview: fromView)
        } else {
            inView.addSubview(toView);
            toView.frame = CGRect(x: 0, y: frame.maxY, width: frame.maxX, height: frame.maxY)
            
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                        if self.reverse {
                            fromView.frame = CGRect(x: 0, y: 0, width: frame.maxX, height: frame.maxY)
                        } else {
                            toView.frame = CGRect(x: 0, y: frame.maxY, width: frame.maxX, height: frame.maxY)
                        }
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }

}
