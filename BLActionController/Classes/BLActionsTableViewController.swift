//
//  BLActionsTableViewController.swift
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
import SwipeCellKit

protocol BLActionsTableCell {
    
    static func nibName() -> String!
    
    var object : BLDataObject?  { get set }
    
    var delegate : SwipeTableViewCellDelegate?  { get set }
}

protocol BLActionViewControllerDelegate {
    
    func actionController<T, C>(addObjectFrom: BLActionsTableViewController<T, C>!)
    
    func actionController<T, C>(editObjectFrom: BLActionsTableViewController<T, C>!, object:T!)
    
    func actionController<T, C>(viewObjectFrom: BLActionsTableViewController<T, C>!, object:T!)
    
    func actionController<T, C>(showDeleteActivity: BLActionsTableViewController<T, C>!)
    
    func actionController<T, C>(dismissDeleteSuccess: BLActionsTableViewController<T, C>!)
    
    func actionController<T, C>(dismissDelete: BLActionsTableViewController<T, C>!, error:Error!)
}

public let kBLErrorSourceDeleteRequest = Int32(50)

public let kBLDefaultEstimatedCellHeight =  CGFloat(140)

class BLActionsTableViewController<T : BLDataObject, C : BLActionsTableCell> : BLListViewController, SwipeTableViewCellDelegate  {
    
    private var inProcessOfRemoving = false
    
    public var allowEditing = true
    
    public var controllerDelegate : BLActionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchObjectsIfNeededOnDisplay = true
        self.tableView.estimatedRowHeight = kBLDefaultEstimatedCellHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: C.nibName(), bundle: nil)
        self.tableView.register(nib,
                                forCellReuseIdentifier: kBLListViewControllerDefaultCellReuseIdentifier)
        if (self.allowEditing) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                     target: self,
                                                                     action: #selector(addObject));
        }
    }
    
    @objc
    func addObject() {
        guard let editDelegate = self.controllerDelegate else {
            preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to add object")
        }
        editDelegate.actionController(addObjectFrom: self)
    }
    
    
    func editObject(_ object : T?) {
        guard let editDelegate = self.controllerDelegate else {
            preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to edit object")
        }
        editDelegate.actionController(editObjectFrom: self, object: object)
    }
    
    func deleteObject(_ object : T?) {
        let alert = UIAlertController(title: "Are you sure?", message: "This action cannot be undone.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: .destructive, handler: { [weak self] (action) in
                                        self?.performDeleteObject(object)
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func performDeleteObject(_ object : T!) {
        
        guard let update = self.dataSource.update else {
            preconditionFailure("You need to provide 'update' for 'dataSource' if you  delete")
        }
        if let editDelegate = self.controllerDelegate {
            editDelegate.actionController(showDeleteActivity: self)
        }
        inProcessOfRemoving = true
        update.delete(object, callback: { [weak self] (result, error) in
            self?.inProcessOfRemoving = false
            guard let error = error else {
                if let editDelegate = self?.controllerDelegate {
                    editDelegate.actionController(dismissDeleteSuccess: self)
                }
                return
            }
            if let errorBlock = self?.errorBlock {
                errorBlock(error, kBLErrorSourceDeleteRequest)
            }
            
            if let editDelegate = self?.controllerDelegate {
                editDelegate.actionController(dismissDelete: self, error: error)
            }
        })
        guard let indexPath = self.dataSource.dataStructure?.indexPath(for: object!) else {
            return;
        }
        self.dataSource.dataStructure?.removeItem(object, fromSection: UInt(indexPath.section))
        self.tableView.deleteRows(at: [indexPath], with: .none)
    }
    
    override func reloadItemsFromSource() {
        if inProcessOfRemoving {
            return
        }
        super.reloadItemsFromSource()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func customize(_ cell: UITableViewCell!, for indexPath: IndexPath!) {
        var theCell = cell as! C
        let object = self.dataSource.dataStructure?.object(for: indexPath)
        theCell.object = object
        theCell.delegate = self
    }
    
    override func cellSelected(at indexPath: IndexPath!) {
        if let object = self.dataSource.dataStructure?.object(for: indexPath) as! T! {
            viewObject(object: object)
        }
    }
    
    func viewObject(object: T!) {
        guard let editDelegate = self.controllerDelegate else {
                preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to edit object")
        }
        editDelegate.actionController(viewObjectFrom: self, object: object)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if self.allowEditing {
            let object = self.dataSource.dataStructure?.object(for: indexPath)
            guard let obj = object, let theObject = obj as? T else {
                return []
            }
            if orientation == .right {
                let edit = SwipeAction(style: .default, title: "Edit", handler: { [weak self] (action, indexPath) in
                    let theCell = self?.tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                    theCell.hideSwipe(animated: true);
                    self?.editObject(theObject)
                })
                let delete = SwipeAction(style: .destructive, title: "Delete", handler: { [weak self] (action, indexPath) in
                    self?.deleteObject(theObject)
                })
                return [delete, edit]
            }
        }
        return []
    }
}
