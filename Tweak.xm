#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static NSString * const CC18LogDirectory = @"/var/mobile/Library/Logs/iPadOS18CC";
static NSString * const CC18LogPath = @"/var/mobile/Library/Logs/iPadOS18CC/cc.log";

static void CC18Log(NSString *format, ...) {
    @autoreleasepool {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        NSDateFormatter *formatter = [NSDateFormatter new];
        NSString *stamp = @"";
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        stamp = [formatter stringFromDate:[NSDate date]];
        NSString *line = [NSString stringWithFormat:@"[%@] %@\n", stamp, message ?: @"(nil)"];
        NSLog(@"[iPadOS18CC] %@", message);
        NSError *error = nil;
        NSFileManager *fm = NSFileManager.defaultManager;
        NSArray<NSString *> *paths = @[CC18LogPath, @"/tmp/iPadOS18CC.log"];
        for (NSString *path in paths) {
            NSString *directory = [path stringByDeletingLastPathComponent];
            error = nil;
            [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) { NSLog(@"[iPadOS18CC] create log directory %@ failed: %@", directory, error); continue; }
            error = nil;
            if (![fm fileExistsAtPath:path]) {
                if (![line writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
                    NSLog(@"[iPadOS18CC] initial log write %@ failed: %@", path, error);
                    continue;
                }
            } else {
                NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
                if (!handle) { NSLog(@"[iPadOS18CC] cannot open log file %@", path); continue; }
                @try { [handle seekToEndOfFile]; [handle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]]; }
                @catch (NSException *exception) { NSLog(@"[iPadOS18CC] log write exception: %@", exception); }
                @finally { [handle closeFile]; }
            }
            break;
        }
    }
}

@interface CCUIControlCenterViewController : UIViewController
@end

static UIView *sHomeIndicator;

static void CC18UncaughtExceptionHandler(NSException *exception) {
    CC18Log(@"UNCAUGHT EXCEPTION: %@\\n%@", exception, exception.callStackSymbols);
}

%ctor {
    @autoreleasepool {
        CC18Log(@"Tweak loaded. process=%@ OS=%@ device=%@", NSProcessInfo.processInfo.processName, UIDevice.currentDevice.systemVersion, UIDevice.currentDevice.model);
        NSSetUncaughtExceptionHandler(CC18UncaughtExceptionHandler);
    }
}

%hook CCUIControlCenterViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    @try {
        UIView *root = self.view;
        CC18Log(@"Control Center did appear: controller=%@ view=%@", NSStringFromClass(self.class), root);
        if (root) {
            root.layer.cornerRadius = 24.0;
            root.layer.masksToBounds = YES;
            if (@available(iOS 13.0, *)) root.backgroundColor = [UIColor colorWithWhite:0.10 alpha:0.88];
        } else {
            CC18Log(@"WARN: CC root view was nil");
        }
    } @catch (NSException *exception) {
        CC18Log(@"CC styling exception: %@\n%@", exception, exception.callStackSymbols);
    }
}
%end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    CC18Log(@"SpringBoard did finish launching");
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            UIWindow *window = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
                    if (scene.activationState != UISceneActivationStateForegroundActive) continue;
                    for (UIWindow *candidate in scene.windows) {
                        if (candidate.isKeyWindow) { window = candidate; break; }
                    }
                    if (window) break;
                }
            }
            if (!window) { CC18Log(@"WARN: key window not found; indicator not added"); return; }
            if (sHomeIndicator) { CC18Log(@"Indicator already exists"); return; }

            CGFloat width = 134.0, height = 5.0, bottomInset = window.safeAreaInsets.bottom;
            CGRect frame = CGRectMake((CGRectGetWidth(window.bounds)-width)/2.0,
                CGRectGetHeight(window.bounds)-MAX(bottomInset,8.0)-height-4.0,width,height);
            sHomeIndicator = [[UIView alloc] initWithFrame:frame];
            sHomeIndicator.backgroundColor = UIColor.whiteColor;
            sHomeIndicator.layer.cornerRadius = height/2.0;
            sHomeIndicator.alpha = 0.85;
            sHomeIndicator.userInteractionEnabled = NO;
            sHomeIndicator.accessibilityIdentifier = @"iPadOS18CC.HomeIndicator";
            [window addSubview:sHomeIndicator];
            CC18Log(@"Home indicator overlay added. frame=%@ safeInsets=%@", NSStringFromCGRect(frame), NSStringFromUIEdgeInsets(window.safeAreaInsets));
        } @catch (NSException *exception) {
            CC18Log(@"Indicator setup exception: %@\n%@", exception, exception.callStackSymbols);
        }
    });
}
%end
