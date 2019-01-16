//
//  XDSMainNoteVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/16.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSMainNoteVC.h"
#import "XDSMainNoteCell.h"
#import "XDSMainReaderVC.h"
#import "XDSNoteHTMLVC.h"
@interface XDSMainNoteVC ()

@property(nonatomic, strong) NSMutableArray *bookModels;
@end

@implementation XDSMainNoteVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XDSMainNoteCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([XDSMainNoteCell class])];
    self.tableView.rowHeight = 105;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVIECE_SCREEN_WIDTH, 1)];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.mj_header = [XDS_CustomMjRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadBooksContainNote)];
    
    self.bookModels = [NSMutableArray arrayWithCapacity:0];
    [self.tableView.mj_header beginRefreshing];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookModels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    XDSMainNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([XDSMainNoteCell class]) forIndexPath:indexPath];
    XDSBookModel *bookModel = self.bookModels[indexPath.row];
    [cell setBookModel:bookModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XDSBookModel *bookModel = self.bookModels[indexPath.row];
    XDSNoteHTMLVC *noteWebVC = [[XDSNoteHTMLVC alloc] init];
    noteWebVC.bookModel = bookModel;
    noteWebVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:noteWebVC animated:YES];
}


- (void)configEmptyPage {
    [self.tableView.mj_header endRefreshing];
    
    __weak typeof(self)weakSelf = self;
    [self.view configWithType:XDSEaseBlankPageTypeEmptyBookNote
                      hasData:self.bookModels.count > 0
                 errorMessage:nil
            reloadButtonBlock:^(XDSEaseBlankPageType pageType) {
                self.tabBarController.selectedIndex = 0;
            } errorReloadButtonBlock:nil];
}

- (void)loadBooksContainNote{
    NSArray<LPPBookInfoModel*> *bookList = [XDSMainReaderVC sharedReaderVC].bookList;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *books_notes = [NSMutableArray arrayWithCapacity:0];
        for (LPPBookInfoModel *bookInfo in bookList) {
            XDSBookModel *bookModel = [XDSBookModel bookModelWithBaseInfo:bookInfo];
            if (bookModel.chapterContainNotes.count > 0) {
                [books_notes addObject:bookModel];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [XDSUtilities hideHud:self.view];
            [self.bookModels removeAllObjects];
            [self.bookModels addObjectsFromArray:books_notes];
            [self.tableView reloadData];
            [self configEmptyPage];
        });
    });
    
}

@end
