//
//  BLSelectTableViewController.swift
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
import BLListViewController

protocol BLSelectTableCell {
    
    static func nibName() -> String!
    
    var object : BLDataObject?  { get set }
    
    var objectSelected : Bool  { get set }
}

protocol BLSelectTableViewControllerDelegate {
    func selectionController<T, C>(_ : BLSelectTableViewController<T, C>!, selectionChanged: [T]!)
    func selectionController<T, C>(_ : BLSelectTableViewController<T, C>!, doneWithSelection: [T]!)
    func selectionController<T, C>(cancelled _ : BLSelectTableViewController<T, C>!)
}

class BLSelectTableViewController<T : BLDataObject, C : BLSelectTableCell> : BLListViewController  {
    
    public var controllerDelegate : BLSelectTableViewControllerDelegate?
    public var allowMultiselection = true
    
    // Put -1 to allow infinite selection
    public var maxSelectedObjectAllowed = -1
    
    var selectedObjects = [T]()
    
    public static func selectionControllerWith(
        dataSource: BLListDataSource!,
        delegate : BLSelectTableViewControllerDelegate?,
        selectedObjects: [T]?) -> UIViewController! {
        let controller = BLSelectTableViewController<T, C>()
        controller.dataSource = dataSource
        if let selectedObjects = selectedObjects {
            controller.selectedObjects += selectedObjects
        }
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchObjectsIfNeededOnDisplay = true
        self.tableView.estimatedRowHeight = kBLDefaultEstimatedCellHeight
        let nib = UINib(nibName: C.nibName(), bundle: nil)
        self.tableView.register(nib,
                                forCellReuseIdentifier: kBLListViewControllerDefaultCellReuseIdentifier)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(doneButtonTapped))
    }
    
    override func customize(_ cell: UITableViewCell!, for indexPath: IndexPath!) {
        var theCell = cell as! C
        let object = self.dataSource.dataStructure?.object(for: indexPath)
        if let obj = object as! T! {
            theCell.object = obj
            theCell.objectSelected = isSelected(object: obj)
        } else {
            theCell.object = nil
            theCell.objectSelected = false
        }
    }
    
    override func cellSelected(at indexPath: IndexPath!) {
        if let object = self.dataSource.dataStructure?.object(for: indexPath) as! T! {
            changeSelectionFor(object: object, indexPath: indexPath)
        }
    }
    
    func changeSelectionFor(object: T!, indexPath : IndexPath!) {
        guard let editDelegate = self.controllerDelegate else {
            preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to edit object")
        }
        
        if let index = selectedPositionOfObject(object: object) {
            selectedObjects.remove(at : index)
        } else {
            selectedObjects.append(object)
        }
        editDelegate.selectionController(self, selectionChanged: selectedObjects)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func cancelButtonTapped() {
        guard let editDelegate = self.controllerDelegate else {
            preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to edit object")
        }
        editDelegate.selectionController(cancelled: self)
    }
    
    @objc func doneButtonTapped() {
        guard let editDelegate = self.controllerDelegate else {
            preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to edit object")
        }
        editDelegate.selectionController(self, doneWithSelection: selectedObjects)
    }
    
    func selectedPositionOfObject(object : T!) -> Int? {
        let position = selectedObjects.index { (obj) -> Bool in
            if let id1 = obj.objectId(), let id2 = object.objectId() {
                return id1 == id2
            }
            return false
        }
        return position
    }
    
    func isSelected(object : T!) -> Bool {
        return selectedPositionOfObject(object: object) != nil
    }
}
