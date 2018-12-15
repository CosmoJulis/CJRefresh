//
//  CJInfiniteScrollingView.h
//  Refresh
//
//  Created by Cosmo Julis on 2018/12/15.
//  Copyright © 2018年 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CJInfiniteScrollingView;

@interface UIScrollView (CJInfiniteScrolling)

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler;
- (void)triggerInfiniteScrolling;

@property (nonatomic, strong, readonly) CJInfiniteScrollingView *infiniteScrollingView;
@property (nonatomic, assign) BOOL showsInfiniteScrolling;

@end


enum {
    CJInfiniteScrollingStateStopped = 0,
    CJInfiniteScrollingStateTriggered,
    CJInfiniteScrollingStateLoading,
    CJInfiniteScrollingStateAll = 10
};

typedef NSUInteger CJInfiniteScrollingState;

@interface CJInfiniteScrollingView : UIView

@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@property (nonatomic, readonly) CJInfiniteScrollingState state;
@property (nonatomic, readwrite) BOOL enabled;

@property (nonatomic) BOOL shouldTriggerActionOnceReachScrollViewBottom; //Without releasing your draging, infiniteScrollingView will trigger action when scrollview scroll to bottom and infiniteScrollingView shows up. Default is NO.

- (void)setCustomView:(UIView *)view forState:(CJInfiniteScrollingState)state;

- (void)startAnimating;
- (void)stopAnimating;

@end
