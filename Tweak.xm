#import <UIKit/UIKit.h>

// Experimental hooks for iPadOS 15.x. Private classes are runtime-checked.
@interface CCUIControlCenterViewController : UIViewController
@end

static UIView *sHomeIndicator;

%hook CCUIControlCenterViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    // Basic visual prototype: rounded translucent Control Center container.
    UIView *root = self.view;
    if (root) {
        root.layer.cornerRadius = 24.0;
        root.layer.masksToBounds = YES;
        if (@available(iOS 13.0, *)) {
            root.backgroundColor = [UIColor colorWithWhite:0.10 alpha:0.88];
        }
    }
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        for (UIWindow *candidate in UIApplication.sharedApplication.windows) {
            if (candidate.isKeyWindow) { window = candidate; break; }
        }
        if (!window || sHomeIndicator) return;

        CGFloat width = 134.0;
        CGFloat height = 5.0;
        CGFloat bottomInset = window.safeAreaInsets.bottom;
        CGRect frame = CGRectMake((CGRectGetWidth(window.bounds) - width) / 2.0,
                                  CGRectGetHeight(window.bounds) - MAX(bottomInset, 8.0) - height - 4.0,
                                  width, height);
        sHomeIndicator = [[UIView alloc] initWithFrame:frame];
        sHomeIndicator.backgroundColor = UIColor.whiteColor;
        sHomeIndicator.layer.cornerRadius = height / 2.0;
        sHomeIndicator.alpha = 0.85;
        sHomeIndicator.userInteractionEnabled = NO;
        [window addSubview:sHomeIndicator];
    });
}

%end
