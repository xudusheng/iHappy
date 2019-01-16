//
//  XDSMainNoteCell.m
//  iHappy
//
//  Created by Hmily on 2019/1/16.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSMainNoteCell.h"

@interface XDSMainNoteCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bookIcon;
@property (weak, nonatomic) IBOutlet UILabel *bookTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteCountLabel;

@end
@implementation XDSMainNoteCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setBookModel:(XDSBookModel *)bookModel {
    _bookModel = bookModel;
    
    UIImage *cover = [UIImage imageWithContentsOfFile:_bookModel.bookBasicInfo.coverPath];
    self.bookIcon.image = cover;
    self.bookTitleLabel.text = _bookModel.bookBasicInfo.title;
    if (_bookModel.chapterContainNotes.count > 0) {
        NSInteger count = 0;
        for (XDSChapterModel *chapter in _bookModel.chapterContainNotes) {
            count += chapter.notes.count;
        }
        self.noteCountLabel.text = [NSString stringWithFormat:@"共%ld个笔记", count];
    }else {
        self.noteCountLabel.text = @"";
    }
    
}

@end
