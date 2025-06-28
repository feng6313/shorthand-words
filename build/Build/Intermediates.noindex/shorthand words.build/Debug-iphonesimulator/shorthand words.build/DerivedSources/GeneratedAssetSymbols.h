#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "arrow" asset catalog image resource.
static NSString * const ACImageNameArrow AC_SWIFT_PRIVATE = @"arrow";

/// The "back" asset catalog image resource.
static NSString * const ACImageNameBack AC_SWIFT_PRIVATE = @"back";

/// The "choose" asset catalog image resource.
static NSString * const ACImageNameChoose AC_SWIFT_PRIVATE = @"choose";

/// The "collect_b" asset catalog image resource.
static NSString * const ACImageNameCollectB AC_SWIFT_PRIVATE = @"collect_b";

/// The "collect_w" asset catalog image resource.
static NSString * const ACImageNameCollectW AC_SWIFT_PRIVATE = @"collect_w";

/// The "down" asset catalog image resource.
static NSString * const ACImageNameDown AC_SWIFT_PRIVATE = @"down";

/// The "lift" asset catalog image resource.
static NSString * const ACImageNameLift AC_SWIFT_PRIVATE = @"lift";

/// The "parting" asset catalog image resource.
static NSString * const ACImageNameParting AC_SWIFT_PRIVATE = @"parting";

/// The "right" asset catalog image resource.
static NSString * const ACImageNameRight AC_SWIFT_PRIVATE = @"right";

/// The "sss" asset catalog image resource.
static NSString * const ACImageNameSss AC_SWIFT_PRIVATE = @"sss";

/// The "up" asset catalog image resource.
static NSString * const ACImageNameUp AC_SWIFT_PRIVATE = @"up";

#undef AC_SWIFT_PRIVATE
