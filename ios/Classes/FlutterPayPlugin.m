#import "FlutterPayPlugin.h"
#if __has_include(<flutter_pay/flutter_pay-Swift.h>)
#import <flutter_pay/flutter_pay-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_pay-Swift.h"
#endif

@implementation FlutterPayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPayPlugin registerWithRegistrar:registrar];
}
@end
