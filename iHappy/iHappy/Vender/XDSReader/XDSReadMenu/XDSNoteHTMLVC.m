//
//  XDSNoteVC.m
//  XDSReader
//
//  Created by Hmily on 2018/10/8.
//  Copyright © 2018年 macos. All rights reserved.
//

#import "XDSNoteHTMLVC.h"

@interface XDSNoteHTMLVC ()

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, copy) NSString *noteString;

@end

@implementation XDSNoteHTMLVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"查看笔记";
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    [self loadResources];
    
//    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
//    self.navigationItem.leftBarButtonItem = leftBar;
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightBar;
}
- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)loadResources {
    
    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle bundleForClass:[XDSNoteHTMLVC class]];
    
    //Create a string with the contents of editor.html
    NSString *filePath = [bundle pathForResource:@"note" ofType:@"html"];
    NSData *noteData = [NSData dataWithContentsOfFile:filePath];
    NSString *noteString = [[NSString alloc] initWithData:noteData encoding:NSUTF8StringEncoding];
    
    //Add jQuery.js to the html file
    NSString *subnotePath = [bundle pathForResource:@"subnote" ofType:@"html"];
    NSData *subnoteData = [NSData dataWithContentsOfFile:subnotePath];
    NSString *subnoteString = [[NSString alloc] initWithData:subnoteData encoding:NSUTF8StringEncoding];
    
    NSMutableString *longNote = [NSMutableString string];
    for (XDSChapterModel *chapter in CURRENT_BOOK_MODEL.chapterContainNotes) {
        for (XDSNoteModel *noteModel in chapter.notes) {
            NSString *subNote = [subnoteString mutableCopy];
            
            NSDate *date = noteModel.date;
            date = date?date:[NSDate date];
            NSString *chapterName = chapter.chapterName;
            chapterName = chapterName.length?chapterName:@"";
            NSString *content = noteModel.content;
            content = content.length?content:@"";
            NSString *note = noteModel.note;
            note = note.length?[NSString stringWithFormat:@"笔记：%@", note]:@"";

            subNote = [subNote stringByReplacingOccurrencesOfString:@"<--date-->" withString:[self stringFromDate:date]];
            subNote = [subNote stringByReplacingOccurrencesOfString:@"<--chaptertitle-->" withString:chapterName];
            subNote = [subNote stringByReplacingOccurrencesOfString:@"<--notecontent-->" withString:content];
            subNote = [subNote stringByReplacingOccurrencesOfString:@"<--note-->" withString:note];
            
            [longNote appendString:subNote];
            [longNote appendString:@"\n"];
        }
    }
    
    LPPBookInfoModel *bookBasicInfo = CURRENT_BOOK_MODEL.bookBasicInfo;
    NSString *title = bookBasicInfo.title;
    title = title.length?title:@"";
    NSString *creator = bookBasicInfo.creator;
    creator = creator.length?creator:@"";
    
    NSString *publisher = @"";
    NSString *owner = @"";
    NSString *protect = @"";
    NSString *publishDate = @"";
    if (creator.length > 0) {
        publisher = [NSString stringWithFormat:@"%@. 《%@》", creator, title];
        owner = @". 小微阅读.";
        protect = @"此材料收版权保护";
        publishDate = bookBasicInfo.date;
    }
    
    noteString = [noteString stringByReplacingOccurrencesOfString:@"<--booktitle-->" withString:title];
    noteString = [noteString stringByReplacingOccurrencesOfString:@"<--author-->" withString:creator];
    noteString = [noteString stringByReplacingOccurrencesOfString:@"<--note-->" withString:longNote];
    
    noteString = [noteString stringByReplacingOccurrencesOfString:@"${publisher}" withString:publisher];
    noteString = [noteString stringByReplacingOccurrencesOfString:@"${owner}" withString:owner];
    noteString = [noteString stringByReplacingOccurrencesOfString:@"${protect}" withString:protect];
    noteString = [noteString stringByReplacingOccurrencesOfString:@"${publishDate}" withString:publishDate];

//    ${publisher}
//    <span style="border-bottom:1px dashed #ccc;" t="5" times="">${publishDate}</span>
//    . 小微阅读. <br>
//    ${protect}
    
    self.noteString = noteString;
    [self.webView loadHTMLString:noteString baseURL:nil];
}


//NSDate转NSString
- (NSString *)stringFromDate:(NSDate *)date{
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    //NSDate转NSString
    NSString *dateString = [dateFormatter stringFromDate:date];
    //输出currentDateString
    NSLog(@"%@",dateString);
    return dateString;
}



- (void)shareAction
{
    NSString *textToShare = [NSString stringWithFormat:@"《%@》的笔记", CURRENT_BOOK_MODEL.bookBasicInfo.title];
    NSURL *urlToShare = [NSURL URLWithString:@"https://www.baidu.com"];
    NSArray *activityItems = @[textToShare, urlToShare];
    [self shareWithContentArray:activityItems];
}

- (void)shareWithContentArray:(NSArray *)contentArray
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:contentArray applicationActivities:nil];
//        activityVC.excludedActivityTypes = @[ UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,UIActivityTypeOpenInIBooks];
    activityVC.completionWithItemsHandler = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError)
    {
        NSLog(@"%@", activityType);
        
        if (completed) { // 确定分享
            NSLog(@"分享成功");
        }
        else {
            NSLog(@"分享失败");
        }
    };
    
    [self presentViewController:activityVC animated:YES completion:nil];
}


@end
