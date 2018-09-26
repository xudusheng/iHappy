//
//  XDSBookModel.m
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/15.
//  Copyright © 2017年 macos. All rights reserved.
//

#import "XDSBookModel.h"
@implementation LPPBookInfoModel

NSString *const kLPPBookInfoModelFullNameEncodeKey = @"fullName";
NSString *const kLPPBookInfoModelRootDocumentUrlEncodeKey = @"rootDocumentUrl";
NSString *const kLPPBookInfoModelOEBPSUrlEncodeKey = @"OEBPSUrl";
NSString *const kLPPBookInfoModelCoverEncodeKey = @"cover";
NSString *const kLPPBookInfoModelTitleEncodeKey = @"title";
NSString *const kLPPBookInfoModelCreatorEncodeKey = @"creator";
NSString *const kLPPBookInfoModelSubjectEncodeKey = @"subject";
NSString *const kLPPBookInfoModelDescripEncodeKey = @"descrip";
NSString *const kLPPBookInfoModelDateEncodeKey = @"date";
NSString *const kLPPBookInfoModelTypeEncodeKey = @"type";
NSString *const kLPPBookInfoModelFormatEncodeKey = @"format";
NSString *const kLPPBookInfoModelIdentifierEncodeKey = @"identifier";
NSString *const kLPPBookInfoModelSourceEncodeKey = @"source";
NSString *const kLPPBookInfoModelRelationEncodeKey = @"relation";
NSString *const kLPPBookInfoModelCoverageEncodeKey = @"coverage";
NSString *const kLPPBookInfoModelRightsEncodeKey = @"rights";
NSString *const kLPPBookInfoModelBookTypeEncodeKey = @"bookType";
NSString *const kLPPBookInfoModelLatestModifyTimeEncodeKey = @"latestModifyTime";

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.fullName forKey:kLPPBookInfoModelFullNameEncodeKey];
    [aCoder encodeObject:self.rootDocumentUrl forKey:kLPPBookInfoModelRootDocumentUrlEncodeKey];
    [aCoder encodeObject:self.OEBPSUrl forKey:kLPPBookInfoModelOEBPSUrlEncodeKey];
    [aCoder encodeObject:self.cover forKey:kLPPBookInfoModelCoverEncodeKey];
    [aCoder encodeObject:self.title forKey:kLPPBookInfoModelTitleEncodeKey];
    [aCoder encodeObject:self.creator forKey:kLPPBookInfoModelCreatorEncodeKey];
    [aCoder encodeObject:self.subject forKey:kLPPBookInfoModelSubjectEncodeKey];
    [aCoder encodeObject:self.descrip forKey:kLPPBookInfoModelDescripEncodeKey];
    [aCoder encodeObject:self.date forKey:kLPPBookInfoModelDateEncodeKey];
    [aCoder encodeObject:self.type forKey:kLPPBookInfoModelTypeEncodeKey];
    [aCoder encodeObject:self.format forKey:kLPPBookInfoModelFormatEncodeKey];
    [aCoder encodeObject:self.identifier forKey:kLPPBookInfoModelIdentifierEncodeKey];
    [aCoder encodeObject:self.source forKey:kLPPBookInfoModelSourceEncodeKey];
    [aCoder encodeObject:self.relation forKey:kLPPBookInfoModelRelationEncodeKey];
    [aCoder encodeObject:self.coverage forKey:kLPPBookInfoModelCoverageEncodeKey];
    [aCoder encodeObject:self.rights forKey:kLPPBookInfoModelRightsEncodeKey];
    [aCoder encodeInteger:self.bookType forKey:kLPPBookInfoModelBookTypeEncodeKey];
    [aCoder encodeDouble:self.latestModifyTime forKey:kLPPBookInfoModelLatestModifyTimeEncodeKey];

}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.fullName = [aDecoder decodeObjectForKey:kLPPBookInfoModelFullNameEncodeKey];
        self.rootDocumentUrl = [aDecoder decodeObjectForKey:kLPPBookInfoModelRootDocumentUrlEncodeKey];
        self.OEBPSUrl = [aDecoder decodeObjectForKey:kLPPBookInfoModelOEBPSUrlEncodeKey];
        self.cover = [aDecoder decodeObjectForKey:kLPPBookInfoModelCoverEncodeKey];
        self.title = [aDecoder decodeObjectForKey:kLPPBookInfoModelTitleEncodeKey];
        self.creator = [aDecoder decodeObjectForKey:kLPPBookInfoModelCreatorEncodeKey];
        self.subject = [aDecoder decodeObjectForKey:kLPPBookInfoModelSubjectEncodeKey];
        self.descrip = [aDecoder decodeObjectForKey:kLPPBookInfoModelDescripEncodeKey];
        self.date = [aDecoder decodeObjectForKey:kLPPBookInfoModelDateEncodeKey];
        self.type = [aDecoder decodeObjectForKey:kLPPBookInfoModelTypeEncodeKey];
        self.format = [aDecoder decodeObjectForKey:kLPPBookInfoModelFormatEncodeKey];
        self.identifier = [aDecoder decodeObjectForKey:kLPPBookInfoModelIdentifierEncodeKey];
        self.source = [aDecoder decodeObjectForKey:kLPPBookInfoModelSourceEncodeKey];
        self.relation = [aDecoder decodeObjectForKey:kLPPBookInfoModelRelationEncodeKey];
        self.coverage = [aDecoder decodeObjectForKey:kLPPBookInfoModelCoverageEncodeKey];
        self.rights = [aDecoder decodeObjectForKey:kLPPBookInfoModelRightsEncodeKey];
        self.bookType = [aDecoder decodeIntegerForKey:kLPPBookInfoModelBookTypeEncodeKey];
        self.latestModifyTime = [aDecoder decodeDoubleForKey:kLPPBookInfoModelLatestModifyTimeEncodeKey];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (NSString *)coverPath {
    if (self.bookType == LPPEBookTypeTxt) {
        return @"";
    }else {
        NSString *OEBPSUrl = self.OEBPSUrl;
        OEBPSUrl = [APP_SANDBOX_DOCUMENT_PATH stringByAppendingString:OEBPSUrl];
        NSString *fileName = [NSString stringWithFormat:@"%@/%@", OEBPSUrl, self.cover];
        return fileName;
    }
    
}

@end

@interface XDSBookModel()
@property (nonatomic,strong) NSMutableArray<XDSChapterModel*> *chapters;//章节
@property (nonatomic,copy) NSArray <XDSChapterModel*> *chapterContainNotes;//包含笔记的章节
@property (nonatomic,copy) NSArray <XDSChapterModel*> *chapterContainMarks;//包含笔记的章节
@end
@implementation XDSBookModel

NSString *const kXDSBookModelBookBasicInfoEncodeKey = @"bookBasicInfo";
NSString *const kXDSBookModelBookTypeEncodeKey = @"bookType";
NSString *const kXDSBookModelChaptersEncodeKey = @"chapters";
NSString *const kXDSBookModelRecordEncodeKey = @"record";

- (instancetype)initWithBookInfo:(LPPBookInfoModel *)bookInfo {
    if (self = [super init]) {
        _chapters = [XDSReadOperation readChaptersWithBookInfo:bookInfo];
        _bookType = bookInfo.bookType;;
        _record = [[XDSRecordModel alloc] init];
        _record.chapterModel = _chapters.firstObject;
        _record.location = 0;
        _bookBasicInfo = bookInfo;
    }
    return self;
}

+ (void)showCoverPage {
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.bookBasicInfo forKey:kXDSBookModelBookBasicInfoEncodeKey];
    [aCoder encodeObject:self.chapters forKey:kXDSBookModelChaptersEncodeKey];
    [aCoder encodeObject:self.record forKey:kXDSBookModelRecordEncodeKey];
    [aCoder encodeObject:@(self.bookType) forKey:kXDSBookModelBookTypeEncodeKey];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.bookBasicInfo = [aDecoder decodeObjectForKey:kXDSBookModelBookBasicInfoEncodeKey];
        self.chapters = [aDecoder decodeObjectForKey:kXDSBookModelChaptersEncodeKey];
        self.record = [aDecoder decodeObjectForKey:kXDSBookModelRecordEncodeKey];
        self.bookType = [[aDecoder decodeObjectForKey:kXDSBookModelBookTypeEncodeKey] integerValue];
    }
    return self;
}

- (void)saveBook {
    
    //保存最近阅读时间
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    self.bookBasicInfo.latestModifyTime = time;
    self.bookBasicInfo.isLastRead = YES;
    
    NSString *key = self.bookBasicInfo.fullName;
    NSMutableData *data=[[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:key];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        
}

+ (id)bookModelWithBaseInfo:(LPPBookInfoModel *)baseInfo{
    if (baseInfo == nil) {
        return nil;
    }
    NSString *key = baseInfo.fullName;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!data) {
        XDSBookModel *model = [[XDSBookModel alloc] initWithBookInfo:baseInfo];
        [model saveBook];
        return model;
    }
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //主线程操作
    XDSBookModel *model = [unarchive decodeObjectForKey:key];
    model.bookBasicInfo = baseInfo;
    return model;
}

- (void)loadContentInChapter:(XDSChapterModel *)chapterModel {
    //load content for current chapter first
    [chapterModel paginateEpubWithBounds:[XDSReadManager readViewBounds]];
}

- (void)loadContentForAllChapters {
    if (![[XDSReadConfig shareInstance] isReadConfigChanged]) {
        return;
    }
    NSInteger index = [self.chapters indexOfObject:CURRENT_RECORD.chapterModel];
    if (index == 0 || index + 1 >= self.chapters.count) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("loadContentForAllChapters", DISPATCH_QUEUE_SERIAL);
    for (NSInteger i = index + 1; i < self.chapters.count; i ++) {
        XDSChapterModel *theChapterModel = self.chapters[i];
        dispatch_async(queue, ^{
            [self loadContentInChapter:theChapterModel];
        });
        
    }
    
    for (NSInteger i = index - 1; i >= 0; i --) {
        XDSChapterModel *theChapterModel = self.chapters[i];
        dispatch_async(queue, ^{
            [self loadContentInChapter:theChapterModel];
        });
    }
    
}

//TODO: Notes
- (void)deleteNote:(XDSNoteModel *)noteModel{
    
}
- (void)addNote:(XDSNoteModel *)noteModel{
    XDSChapterModel *chapterModel = self.chapters[noteModel.chapter];
    [chapterModel addNote:noteModel];
//    [XDSBookModel updateLocalModel:self url:self.resource]; //本地保存
    [self devideChaptersContainNotes];
}

- (void)devideChaptersContainNotes{
    NSMutableArray *chapterContainNotes = [NSMutableArray arrayWithCapacity:0];
    for (XDSChapterModel *chapterModel in self.chapters) {
        if (chapterModel.notes.count) {
            [chapterContainNotes addObject:chapterModel];
        }
    }
    self.chapterContainNotes = chapterContainNotes;
}

- (NSArray<XDSChapterModel *> *)chapterContainNotes{
    if (nil == _chapterContainNotes) {
        [self devideChaptersContainNotes];
    }
    return _chapterContainNotes;
}


//TODO: Marks
- (void)deleteMark:(XDSMarkModel *)markModel{
    [self addMark:markModel];
}
- (void)addMark:(XDSMarkModel *)markModel{
    XDSChapterModel *chapterModel = self.chapters[markModel.chapter];
    
    if (chapterModel.isReadConfigChanged) {
        [CURRENT_BOOK_MODEL loadContentInChapter:chapterModel];
    }
    [chapterModel addOrDeleteABookmark:markModel];
//    [XDSBookModel updateLocalModel:self url:self.resource]; //本地保存
    [self devideChaptersContainMarks];
}

- (void)devideChaptersContainMarks{
    NSMutableArray *chapterContainMarks = [NSMutableArray arrayWithCapacity:0];
    for (XDSChapterModel *chapterModel in self.chapters) {
        if (chapterModel.marks.count) {
            [chapterContainMarks addObject:chapterModel];
        }
    }
    self.chapterContainMarks = chapterContainMarks;
}

- (NSArray<XDSChapterModel *> *)chapterContainMarks{
    if (nil == _chapterContainMarks) {
        [self devideChaptersContainMarks];
    }
    return _chapterContainMarks;
}

@end
