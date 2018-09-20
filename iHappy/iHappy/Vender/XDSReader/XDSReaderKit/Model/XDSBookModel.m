//
//  XDSBookModel.m
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/15.
//  Copyright © 2017年 macos. All rights reserved.
//

#import "XDSBookModel.h"
@implementation LPPBookInfoModel

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

- (void)encodeWithCoder:(NSCoder *)aCoder{
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

}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
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
NSString *const kXDSBookModelResourceEncodeKey = @"resource";
NSString *const kXDSBookModelContentEncodeKey = @"content";
NSString *const kXDSBookModelBookTypeEncodeKey = @"bookType";
NSString *const kXDSBookModelChaptersEncodeKey = @"chapters";
NSString *const kXDSBookModelRecordEncodeKey = @"record";

- (instancetype)initWithContent:(NSString *)content{
    self = [super init];
    if (self) {
        _content = content;
        NSMutableArray *charpter = [NSMutableArray array];
        [XDSReadOperation separateChapter:&charpter content:content];
        _chapters = charpter;
        _record = [[XDSRecordModel alloc] init];
        _record.chapterModel = charpter.firstObject;
        _record.location = 0;
        _bookType = LPPEBookTypeTxt;
    }
    return self;
}
- (instancetype)initWithePub:(NSString *)ePubPath{
    self = [super init];
    if (self) {
        _bookBasicInfo = [[LPPBookInfoModel alloc] init];
        _bookBasicInfo.bookType = LPPEBookTypeEpub;
        _chapters = [XDSReadOperation ePubFileHandle:ePubPath bookInfoModel:_bookBasicInfo];
        _record = [[XDSRecordModel alloc] init];
        _record.chapterModel = _chapters.firstObject;
        _record.location = 0;
        _bookType = LPPEBookTypeEpub;
    }
    return self;
}
+ (void)showCoverPage {
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.bookBasicInfo forKey:kXDSBookModelBookBasicInfoEncodeKey];
    [aCoder encodeObject:self.content forKey:kXDSBookModelContentEncodeKey];
    [aCoder encodeObject:self.chapters forKey:kXDSBookModelChaptersEncodeKey];
    [aCoder encodeObject:self.record forKey:kXDSBookModelRecordEncodeKey];
    [aCoder encodeObject:self.resource forKey:kXDSBookModelResourceEncodeKey];
    [aCoder encodeObject:@(self.bookType) forKey:kXDSBookModelBookTypeEncodeKey];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.bookBasicInfo = [aDecoder decodeObjectForKey:kXDSBookModelBookBasicInfoEncodeKey];
        self.content = [aDecoder decodeObjectForKey:kXDSBookModelContentEncodeKey];
        self.chapters = [aDecoder decodeObjectForKey:kXDSBookModelChaptersEncodeKey];
        self.record = [aDecoder decodeObjectForKey:kXDSBookModelRecordEncodeKey];
        self.resource = [aDecoder decodeObjectForKey:kXDSBookModelResourceEncodeKey];
        self.bookType = [[aDecoder decodeObjectForKey:kXDSBookModelBookTypeEncodeKey] integerValue];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"bookModel dealloc");
    [self saveBook];
}

- (void)saveBook {
        NSString *key = [self.resource.path lastPathComponent];
        NSMutableData *data=[[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:self forKey:key];
        [archiver finishEncoding];

        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        
}
//14631822

//+ (void)updateLocalModel:(XDSBookModel *)readModel url:(NSURL *)url{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSString *key = [url.path lastPathComponent];
//        NSMutableData *data=[[NSMutableData alloc]init];
//        NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//        [archiver encodeObject:readModel forKey:key];
//        [archiver finishEncoding];
//        NSLog(@"111111111");
//        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
//        NSLog(@"222222222");
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSLog(@"33333333");
//    });
//
//}
+ (id)getLocalModelWithURL:(NSURL *)url{
    if (url == nil) {
        return nil;
    }
    NSString *key = [url.path lastPathComponent];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!data) {
        if ([[key pathExtension].lowercaseString isEqualToString:@"txt"]) {
            XDSBookModel *model = [[XDSBookModel alloc] initWithContent:[XDSReaderUtil encodeWithURL:url]];
            model.resource = url;
            LPPBookInfoModel *info = [[LPPBookInfoModel alloc] init];
            info.bookType = LPPEBookTypeTxt;
            info.title = [key substringToIndex:key.length-4];
            model.bookBasicInfo = info;
//            [XDSBookModel updateLocalModel:model url:url];
            return model;
        }else if ([[key pathExtension].lowercaseString isEqualToString:@"epub"]){
            NSLog(@"this is epub");
            XDSBookModel *model = [[XDSBookModel alloc] initWithePub:url.path];
            model.resource = url;
//            [XDSBookModel updateLocalModel:model url:url];
            return model;
        }else{
//            @throw [NSException exceptionWithName:@"FileException" reason:@"文件格式错误" userInfo:nil];
//            文件格式错误
            NSLog(@"文件格式错误");
            return nil;
        }
        
    }
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    //主线程操作
    XDSBookModel *model = [unarchive decodeObjectForKey:key];
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
