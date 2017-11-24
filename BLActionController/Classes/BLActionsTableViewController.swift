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

public protocol BLActionsTableCell {
    
    static func nibName() -> String!
    
    var object : BLDataObject?  { get set }
    
    var delegate : SwipeTableViewCellDelegate?  { get set }
}

public protocol BLActionViewControllerDelegate {
    
    func action<T, C>(addObjectFrom controller: BLActionsTableViewController<T, C>!)
    
    func action<T, C>(editObjectFrom controller: BLActionsTableViewController<T, C>!, object:T!)
    
    func action<T, C>(viewObjectFrom controller: BLActionsTableViewController<T, C>!, object:T!)
    
    func action<T, C>(promptToDelete controller: BLActionsTableViewController<T, C>!, object:T!, deleteCallback:@escaping (()->()))
    
    func action<T, C>(showDeleteActivity controller: BLActionsTableViewController<T, C>!)
    
    func action<T, C>(dismissDeleteSuccess controller: BLActionsTableViewController<T, C>!)
    
    func action<T, C>(dismissDelete controller: BLActionsTableViewController<T, C>!, error:Error!)
}

public let kBLErrorSourceDeleteRequest = Int32(50)

public let kBLDefaultEstimatedCellHeight =  CGFloat(140)

open class BLActionsTableViewController<T : BLDataObject, C : BLActionsTableCell> : BLListViewController, SwipeTableViewCellDelegate  {
    
    private var inProcessOfRemoving = false
    
    public var allowEditing = true
    
    public var editTitle = "Edit"
    public var editImage : UIImage?
    public var deleteTitle = "Delete"
    public var deleteImage : UIImage?
    
    public var controllerDelegate : BLActionViewControllerDelegate?
    
    override open func viewDidLoad() {
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
        editDelegate.action(addObjectFrom: self)
    }
    
    
    func editObject(_ object : T?) {
        guard let editDelegate = self.controllerDelegate else {
            preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to edit object")
        }
        editDelegate.action(editObjectFrom: self, object: object)
    }
    
    func deleteObject(_ object : T?) {
        guard let editDelegate = self.controllerDelegate else {
            preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to edit object")
        }
        editDelegate.action(promptToDelete: self, object: object) { [weak self] in
            self?.performDeleteObject(object)
        };
    }
    
    private func performDeleteObject(_ object : T!) {
        
        guard let update = self.dataSource.update else {
            preconditionFailure("You need to provide 'update' for 'dataSource' if you  delete")
        }
        if let editDelegate = self.controllerDelegate {
            editDelegate.action(showDeleteActivity: self)
        }
        inProcessOfRemoving = true
        update.delete(object, callback: { [weak self] (result, error) in
            self?.inProcessOfRemoving = false
            guard let error = error else {
                if let editDelegate = self?.controllerDelegate {
                    editDelegate.action(dismissDeleteSuccess: self)
                }
                return
            }
            if let errorBlock = self?.errorBlock {
                errorBlock(error, kBLErrorSourceDeleteRequest)
            }
            
            if let editDelegate = self?.controllerDelegate {
                editDelegate.action(dismissDelete: self, error: error)
            }
        })
        guard let indexPath = self.dataSource.dataStructure?.indexPath(for: object!) else {
            return;
        }
        self.dataSource.dataStructure?.removeItem(object, fromSection: UInt(indexPath.section))
        self.tableView.deleteRows(at: [indexPath], with: .none)
    }
    
    override open func reloadItemsFromSource() {
        if inProcessOfRemoving {
            return
        }
        super.reloadItemsFromSource()
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override open func customize(_ cell: UITableViewCell!, for indexPath: IndexPath!) {
        var theCell = cell as! C
        let object = self.dataSource.dataStructure?.object(for: indexPath)
        theCell.object = object
        theCell.delegate = self
    }
    
    override open func cellSelected(at indexPath: IndexPath!) {
        if let object = self.dataSource.dataStructure?.object(for: indexPath) as! T! {
            viewObject(object: object)
        }
    }
    
    func viewObject(object: T!) {
        guard let editDelegate = self.controllerDelegate else {
                preconditionFailure("You need to provide 'controllerDelegate' if you planning to allow user to edit object")
        }
        editDelegate.action(viewObjectFrom: self, object: object)
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if self.allowEditing {
            let object = self.dataSource.dataStructure?.object(for: indexPath)
            guard let obj = object, let theObject = obj as? T else {
                return []
            }
            if orientation == .right {
                let edit = SwipeAction(style: .default, title: editTitle, handler: { [weak self] (action, indexPath) in
                    let theCell = self?.tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                    theCell.hideSwipe(animated: true);
                    self?.editObject(theObject)
                })
                edit.image = editImage
                let delete = SwipeAction(style: .destructive, title: deleteTitle, handler: { [weak self] (action, indexPath) in
                    self?.deleteObject(theObject)
                })
                delete.image = deleteImage
                return [delete, edit]
            }
        }
        return []
    }
}
