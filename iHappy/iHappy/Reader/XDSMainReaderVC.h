//
//  XDSMainReaderVC.h
//  iHappy
//
//  Created by Hmily on 2018/9/17.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XDSMainReaderVC : UIViewController

+ (instancetype)sharedReaderVC;

@property (nonatomic, readonly) NSMutableArray<LPPBookInfoModel*> * bookList;

@end
