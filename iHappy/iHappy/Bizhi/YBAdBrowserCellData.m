//
//  YBAdBrowserCellData.m
//  iHappy
//
//  Created by Hmily on 2018/11/30.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "YBAdBrowserCellData.h"
#import "YBAdBrowserCell.h"

@implementation YBAdBrowserCellData

- (Class)yb_classOfBrowserCell {
    return YBAdBrowserCell.class;
}

- (id)yb_browserCellSourceObject {
    return nil;
}

- (BOOL)yb_browserAllowSaveToPhotoAlbum {
    return NO;
}
- (void)yb_browserSaveToPhotoAlbum {
    
}

- (BOOL)yb_browserAllowShowSheetView {
    return NO;
}

- (void)yb_preload {
 //load ad
    
}


@end
