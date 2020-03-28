// Douglas Hill, March 2020

#import "AppDelegate.h"
#import "ClassicDemoViewController.h"
@import KeyboardKit;

#define let __auto_type const

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    let viewController = [[ClassicDemoViewController alloc] init];
    [viewController setTitle:@"KeyboardKit Classic Demo"];

    let window = [[KeyboardWindow alloc] init];
    [window setRootViewController:[[KeyboardNavigationController alloc] initWithRootViewController:viewController]];
    [window makeKeyAndVisible];
    [self setWindow:window];

    return YES;
}

@end
