//
//  CJPullToRefreshView.m
//  Refresh
//
//  Created by Cosmo Julis on 2018/12/15.
//  Copyright © 2018年 Demo. All rights reserved.
//

#import "CJPullToRefreshView.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation CJPullToRefreshTitleLabel

- (void)setColor:(UIColor *)color {
    self.textColor = color;
}

- (UIColor *)color {
    return self.textColor;
}

@end

typedef NS_ENUM(NSInteger, CJPullToRefreshViewState) {
    CJPullToRefreshViewStateStopped,
    CJPullToRefreshViewStateTriggered,
    CJPullToRefreshViewStateLoading
};

CGFloat const CJPullToRefreshViewHeight = 52;

@interface CJPullToRefreshView () <UIScrollViewDelegate>
@property (nonatomic,weak)              UIView                      *contentView;
@property (nonatomic,weak)              UIImageView                 *backgroundImageView;
@property (nonatomic,weak)              CJPullToRefreshTitleLabel   *titleLabel;
@property (nonatomic,weak)              UIActivityIndicatorView     *activityIndicatorView;
@property (nonatomic)                   CJPullToRefreshViewState    state;
@property (nonatomic,readonly)          UIScrollView                *scrollView;
@property (nonatomic)                   BOOL                        isAnimating;
@end

@implementation CJPullToRefreshView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [self.backgroundImageView setImage:backgroundImage];
}

- (void)setup {
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    self.contentView = contentView;

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundImageView.contentMode = UIViewContentModeBottom;
    [self.contentView addSubview:backgroundImageView];
    self.backgroundImageView = backgroundImageView;

    CJPullToRefreshTitleLabel *titleLabel = [[CJPullToRefreshTitleLabel alloc] initWithFrame:self.contentView.bounds];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;

    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.color = [UIColor whiteColor];
    activityIndicatorView.center = titleLabel.center;
    activityIndicatorView.hidesWhenStopped = YES;
    [activityIndicatorView startAnimating];
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:activityIndicatorView];
    self.activityIndicatorView = activityIndicatorView;

    [self hideContentViewAnimated:NO];
    [self updateUIForStoppedState];
    self.state = CJPullToRefreshViewStateStopped;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.state != CJPullToRefreshViewStateLoading) {
        CGFloat scrollOffsetThreshold = self.frame.origin.y - scrollView.contentInset.top;

        if(!scrollView.isDragging && self.state == CJPullToRefreshViewStateTriggered && scrollView.contentOffset.y + scrollView.contentInset.top < 0) {
            self.state = CJPullToRefreshViewStateLoading;
        }
        else if(scrollView.contentOffset.y < scrollOffsetThreshold && scrollView.isDragging && self.state == CJPullToRefreshViewStateStopped) {
            AudioServicesPlaySystemSound(1519);
            self.state = CJPullToRefreshViewStateTriggered;
        }
        else if(scrollView.contentOffset.y >= scrollOffsetThreshold) {
            CGFloat alpha = 1 - (scrollOffsetThreshold - scrollView.contentOffset.y)/(self.frame.origin.y/2);
            alpha = (alpha<1.0)?alpha:1.0;
            self.contentView.alpha = alpha;
            self.state = CJPullToRefreshViewStateStopped;
        }
    }
}

- (UIScrollView *)scrollView {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        return (id)self.superview;
    }
    return nil;
}

- (void)hideContentViewAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            self.contentView.alpha = 0;
        } completion:nil];
    } else {
        self.contentView.alpha = 0;
    }
}

- (void)addAnimationTransitionToTitleLabel {
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.1;
    [self.titleLabel.layer addAnimation:transition forKey:nil];
}

- (void)updateUIForStoppedState {
    [self addAnimationTransitionToTitleLabel];
    self.activityIndicatorView.alpha = 0;
}

- (void)updateUIForLoadingState {
    [self addAnimationTransitionToTitleLabel];
    self.contentView.alpha = 1;
    self.activityIndicatorView.alpha = 1;
    [self startAnimating];
}

- (void)updateUIForTriggeredState {
    [self addAnimationTransitionToTitleLabel];
    self.contentView.alpha = 1;
    self.activityIndicatorView.alpha = 0;
}

- (void)setState:(CJPullToRefreshViewState)state {
    if(_state == state)
        return;

    CJPullToRefreshViewState previousState = _state;
    _state = state;

    switch (state) {
        case CJPullToRefreshViewStateStopped:{
            [self updateUIForStoppedState];
        }break;
        case CJPullToRefreshViewStateLoading:{
            if(previousState == CJPullToRefreshViewStateTriggered && self.pullToRefreshActionHandler) {
                [self updateUIForLoadingState];
                double delayInSeconds = 0.3;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if (self.pullToRefreshActionHandler) self.pullToRefreshActionHandler();
                });
            }
        }break;
        case CJPullToRefreshViewStateTriggered:{
            [self updateUIForTriggeredState];
        }break;
        default:
            break;
    }
}

- (void)startAnimating{
    if (!self.isAnimating) {
        self.isAnimating = YES;

        self.state = CJPullToRefreshViewStateLoading;

        UIEdgeInsets contentInset = self.scrollView.contentInset;
        contentInset.top += CGRectGetHeight(self.bounds);

        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.contentView.alpha = 1;
                             self.scrollView.contentInset = contentInset;
                             [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -contentInset.top) animated:YES];
                         } completion:nil];
    }
}

- (void)stopAnimating {
    if (self.isAnimating) {
        self.isAnimating = NO;

        UIEdgeInsets contentInset = self.scrollView.contentInset;
        contentInset.top -= CGRectGetHeight(self.bounds);
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.scrollView.contentInset = contentInset;
                         } completion:^(BOOL finished) {
                    [self hideContentViewAnimated:YES];
                    self.state = CJPullToRefreshViewStateStopped;
                }];
    }
}


@end

#import <objc/runtime.h>

static void class_swizzleSelector(Class class, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    if(class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

NSString * const CJScrollViewPullToRefreshViewAssociationKey = @"CJScrollViewPullToRefreshViewAssociationKey";

@implementation UIScrollView (CJPullToRefreshView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            class_swizzleSelector(self, NSSelectorFromString([@"_notify" stringByAppendingString:@"DidScroll"]), @selector(_notifyDidScroll_pullToRefresh));
        }
    });
}

- (void)_notifyDidScroll_pullToRefresh {
    [self _notifyDidScroll_pullToRefresh];
    if(self.showsPullToRefresh) [self.pullToRefreshView scrollViewDidScroll:self];
}

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler {
    if(!self.pullToRefreshView) {
        CJPullToRefreshView *view = [[CJPullToRefreshView alloc] initWithFrame:CGRectMake(0, -CJPullToRefreshViewHeight, self.bounds.size.width - self.contentInset.left - self.contentInset.right, CJPullToRefreshViewHeight)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:view];

        self.pullToRefreshView = view;
        self.showsPullToRefresh = YES;
    }
    self.pullToRefreshView.pullToRefreshActionHandler = actionHandler;
}

- (void)triggerPullToRefresh {
    if (self.pullToRefreshView.state != CJPullToRefreshViewStateStopped) return;

    self.pullToRefreshView.state = CJPullToRefreshViewStateTriggered;
    [self.pullToRefreshView startAnimating];
}

- (void)setPullToRefreshView:(CJPullToRefreshView *)pullToRefreshView {
    objc_setAssociatedObject(self, &CJScrollViewPullToRefreshViewAssociationKey, pullToRefreshView, OBJC_ASSOCIATION_ASSIGN);
}

- (CJPullToRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &CJScrollViewPullToRefreshViewAssociationKey);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshView.hidden = !showsPullToRefresh;
}

- (BOOL)showsPullToRefresh {
    return !self.pullToRefreshView.hidden;
}

@end
