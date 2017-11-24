//
//  BLListViewController.h
//  https://github.com/batkov/BLListViewController
//
// Copyright (c) 2016 Hariton Batkov
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

#import <UIKit/UIKit.h>
@import BLListDataSource;

extern NSString * const kBLListViewControllerDefaultCellReuseIdentifier;
static const int kBLListViewControllerDefaultCellHeight = 50.f;

static const int kBLErrorSourceFetchObject = 40.f;

@interface BLListViewController : UIViewController

// Set data source that will work for this controller
@property (nonatomic, strong) BLListDataSource * dataSource;

// or set 'fetch' and 'update' before first dataSource call
// and BLListDataSource will be created with them
@property (nonatomic, strong) id <BLBaseFetch> fetch;
@property (nonatomic, strong) id <BLBaseUpdate> update;

// Default is YES. Asks subclasses whether it should create loadMoreController or not.
@property (nonatomic, assign) BOOL loadMoreEnabled;
// Default is YES. Asks subclasses whether it should create refreshController or not.
@property (nonatomic, assign) BOOL pullToRefreshEnabled;

// Default is NO. Invert actions for refresh and load more controls.
// Used in reverse lists like chat
@property (nonatomic, assign) BOOL invertPullToRefreshControllers;

// Default is NO. If YES 'BLDataObject' will ask whether 'isDataAvailable' or 'isAllDataAvailable'
// and asked for 'dataSource' to fetch object
@property (nonatomic, assign) BOOL fetchObjectsIfNeededOnDisplay;

@property (nonatomic, copy) BLErrorBlock errorBlock;
@end
