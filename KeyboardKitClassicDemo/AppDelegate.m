// Douglas Hill, March 2020

#import "AppDelegate.h"
#import "ClassicDemoViewController.h"
@import KeyboardKit;

#define let __auto_type const

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    let viewController1 = [[ClassicDemoViewController alloc] init];
    [viewController1 setTitle:@"Demo 1"];

    let viewController2 = [[ClassicDemoViewController alloc] init];
    [viewController2 setTitle:@"Demo 2"];

    let tabBarController = [[KeyboardTabBarController alloc] init];
    tabBarController.viewControllers = @[
        [[KeyboardNavigationController alloc] initWithRootViewController:viewController1],
        [[KeyboardNavigationController alloc] initWithRootViewController:viewController2],
    ];

    let window = [[KeyboardWindow alloc] init];
    [window setRootViewController:tabBarController];
    [window makeKeyAndVisible];
    [self setWindow:window];

    return YES;
}

@end
