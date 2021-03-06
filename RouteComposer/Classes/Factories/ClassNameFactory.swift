//
// Created by Eugene Kazaev on 15/01/2018.
// Copyright (c) 2018 HBC Tech. All rights reserved.
//

import UIKit

/// The `Factory` that creates a `UIViewController` class by its name
public struct ClassNameFactory<VC: UIViewController, C>: Factory {

    public typealias ViewController = VC

    public typealias Context = C

    /// The name of a `UIViewController` class to be built by the `Factory`
    public let viewControllerName: String

    /// Constructor
    ///
    /// - Parameters:
    ///   - viewControllerName: The name of a `UIViewController` class to be built
    public init(viewControllerName: String) {
        self.viewControllerName = viewControllerName
    }

    public func build(with context: Context) throws -> ViewController {
        guard let customClass = NSClassFromString(self.viewControllerName) else {
            throw RoutingError.message("Can not find \(self.viewControllerName) in bundle")
        }
        guard let customViewControllerClass = customClass as? ViewController.Type else {
            throw RoutingError.message("\(self.viewControllerName) is not a UIViewController type class.")
        }

        return customViewControllerClass.init(nibName: nil, bundle: nil)
    }

}
