//
//  CJPullToRefreshView.h
//  Refresh
//
//  Created by Cosmo Julis on 2018/12/15.
//  Copyright © 2018年 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CJPullToRefreshTitleLabelColor [UIColor colorWithThemeKey:@"text_sub"]

@interface CJPullToRefreshTitleLabel : UILabel

@property (nonatomic,copy) UIColor *color;

@end

@interface CJPullToRefreshView : UIView
@property (nonatomic,strong) UIImage *backgroundImage;
@property (nonatomic,weak,readonly) CJPullToRefreshTitleLabel *titleLabel;
@property (nonatomic,weak,readonly) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic,copy) void (^pullToRefreshActionHandler)(void);
@property (nonatomic,readonly) BOOL isAnimating;

- (void)stopAnimating;
@end



@interface UIScrollView (CJPullToRefreshView)

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler;
- (void)triggerPullToRefresh;

@property (nonatomic, strong, readonly) CJPullToRefreshView *pullToRefreshView;
@property (nonatomic, assign) BOOL showsPullToRefresh;

@end
