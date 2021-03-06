//
// Created by Eugene Kazaev on 25/07/2018.
//

import Foundation
import UIKit

/// A simple class that produces intermediate `RoutingStep` for an assembly.
public final class SingleStep<F: Finder, FC: Factory>: StepWithActionAssembly<F, FC>
        where F.ViewController == FC.ViewController, F.Context == FC.Context {

    let finder: F

    let factory: FC

    /// Creates a instance of the `RoutingStep` that produces container view controller.
    ///
    /// - Parameters:
    ///   - finder: The `UIViewController` `Finder`.
    ///   - factory: The `UIViewController` `Factory`.
    public init(finder: F, factory: FC) {
        self.finder = finder
        self.factory = factory
    }

    override func routingStep<A: Action>(with action: A) -> RoutingStep {
        return BaseStep<FactoryBox<FC>>(finder: finder,
                factory: factory,
                action: ActionBox(action),
                interceptor: taskCollector.interceptor(),
                contextTask: taskCollector.contextTask(),
                postTask: taskCollector.postTask(),
                previousStep: nil
        )
    }

    override func embeddableRoutingStep<A: ContainerAction>(with action: A) -> RoutingStep {
        return BaseStep<FactoryBox<FC>>(finder: finder,
                factory: factory,
                action: ContainerActionBox(action),
                interceptor: taskCollector.interceptor(),
                contextTask: taskCollector.contextTask(),
                postTask: taskCollector.postTask(),
                previousStep: nil
        )
    }
}
