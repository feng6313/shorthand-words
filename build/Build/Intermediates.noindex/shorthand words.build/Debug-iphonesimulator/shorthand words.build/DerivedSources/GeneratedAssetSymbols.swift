import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "arrow" asset catalog image resource.
    static let arrow = DeveloperToolsSupport.ImageResource(name: "arrow", bundle: resourceBundle)

    /// The "back" asset catalog image resource.
    static let back = DeveloperToolsSupport.ImageResource(name: "back", bundle: resourceBundle)

    /// The "choose" asset catalog image resource.
    static let choose = DeveloperToolsSupport.ImageResource(name: "choose", bundle: resourceBundle)

    /// The "collect_b" asset catalog image resource.
    static let collectB = DeveloperToolsSupport.ImageResource(name: "collect_b", bundle: resourceBundle)

    /// The "collect_w" asset catalog image resource.
    static let collectW = DeveloperToolsSupport.ImageResource(name: "collect_w", bundle: resourceBundle)

    /// The "down" asset catalog image resource.
    static let down = DeveloperToolsSupport.ImageResource(name: "down", bundle: resourceBundle)

    /// The "lift" asset catalog image resource.
    static let lift = DeveloperToolsSupport.ImageResource(name: "lift", bundle: resourceBundle)

    /// The "parting" asset catalog image resource.
    static let parting = DeveloperToolsSupport.ImageResource(name: "parting", bundle: resourceBundle)

    /// The "right" asset catalog image resource.
    static let right = DeveloperToolsSupport.ImageResource(name: "right", bundle: resourceBundle)

    /// The "sss" asset catalog image resource.
    static let sss = DeveloperToolsSupport.ImageResource(name: "sss", bundle: resourceBundle)

    /// The "up" asset catalog image resource.
    static let up = DeveloperToolsSupport.ImageResource(name: "up", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "arrow" asset catalog image.
    static var arrow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .arrow)
#else
        .init()
#endif
    }

    /// The "back" asset catalog image.
    static var back: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .back)
#else
        .init()
#endif
    }

    /// The "choose" asset catalog image.
    static var choose: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .choose)
#else
        .init()
#endif
    }

    /// The "collect_b" asset catalog image.
    static var collectB: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .collectB)
#else
        .init()
#endif
    }

    /// The "collect_w" asset catalog image.
    static var collectW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .collectW)
#else
        .init()
#endif
    }

    /// The "down" asset catalog image.
    static var down: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .down)
#else
        .init()
#endif
    }

    /// The "lift" asset catalog image.
    static var lift: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lift)
#else
        .init()
#endif
    }

    /// The "parting" asset catalog image.
    static var parting: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .parting)
#else
        .init()
#endif
    }

    /// The "right" asset catalog image.
    static var right: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .right)
#else
        .init()
#endif
    }

    /// The "sss" asset catalog image.
    static var sss: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sss)
#else
        .init()
#endif
    }

    /// The "up" asset catalog image.
    static var up: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .up)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "arrow" asset catalog image.
    static var arrow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .arrow)
#else
        .init()
#endif
    }

    /// The "back" asset catalog image.
    static var back: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .back)
#else
        .init()
#endif
    }

    /// The "choose" asset catalog image.
    static var choose: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .choose)
#else
        .init()
#endif
    }

    /// The "collect_b" asset catalog image.
    static var collectB: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .collectB)
#else
        .init()
#endif
    }

    /// The "collect_w" asset catalog image.
    static var collectW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .collectW)
#else
        .init()
#endif
    }

    /// The "down" asset catalog image.
    static var down: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .down)
#else
        .init()
#endif
    }

    /// The "lift" asset catalog image.
    static var lift: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lift)
#else
        .init()
#endif
    }

    /// The "parting" asset catalog image.
    static var parting: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .parting)
#else
        .init()
#endif
    }

    /// The "right" asset catalog image.
    static var right: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .right)
#else
        .init()
#endif
    }

    /// The "sss" asset catalog image.
    static var sss: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sss)
#else
        .init()
#endif
    }

    /// The "up" asset catalog image.
    static var up: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .up)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

