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

public let kBLActionControllerMapStoryboardName = "Map"
public let kBLActionControllerMapNavIdentifier = "nav_map"
public let kBLActionControllerMapIdentifier = "map"
public let kBLActionControllerMapListIdentifier = "list"

public protocol BLMapObject : MKAnnotation {
    func isAnnotationAvailable() -> Bool
}

open class BLMapListController : UIViewController, MKMapViewDelegate {
    var dataSource : BLListDataSource?
    let clusteringManager = FBClusteringManager()
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var seeListButton: UIButton!
    
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
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == kBLActionControllerMapListIdentifier else {
            return
        }
        let destination = segue.destination
        if let list = destination as? BLListViewController {
            list.dataSource = dataSource!
        }
    }
    
    func reloadMap() {
        guard let dataSource = dataSource else {
            return
        }
        seeListButton.alpha = dataSource.hasContent() ? 1 : 0
        mapView(mapView, regionDidChangeAnimated: false)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
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
            self?.clusteringManager.setAnnotations(annotations)
            self?.reloadMap()
        }
        reloadMap()
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        OperationQueue().addOperation { [weak self] in
            let scale = Double(mapView.bounds.size.width) / Double(mapView.visibleMapRect.size.width)
            let annotations = self?.clusteringManager.clusteredAnnotations(within: mapView.visibleMapRect, withZoomScale: scale)
            
            self?.clusteringManager.displayAnnotations(annotations, on: mapView)
        }
    }
    
}
