//
// Created by Eugene Kazaev on 14/02/2018.
//

import Foundation
import UIKit

/// Builds tree of `RoutingStep` which will be taken by a `Router` and adds a condition to the each step when it should
/// be taken.
public final class SwitchAssembly {

    private struct BlockResolver<Destination>: StepCaseResolver {

        let resolverBlock: ((_: Destination) -> RoutingStep?)

        init(resolverBlock: @escaping ((_: Destination) -> RoutingStep?)) {
            self.resolverBlock = resolverBlock
        }

        func resolve<D: RoutingDestination>(for destination: D) -> RoutingStep? {
            guard let typedDestination = destination as? Destination else {
                return nil
            }
            return resolverBlock(typedDestination)
        }
    }

    private struct FinderStep: RoutingStep, PerformableStep {

        let finder: AnyFinder?

        init<F: Finder>(finder: F) {
            self.finder = FinderBox.box(for: finder)
        }

        func perform<D: RoutingDestination>(for destination: D) -> StepResult {
            guard let viewController = finder?.findViewController(with: destination.context) else {
                return .failure
            }
            return .success(viewController)
        }
    }

    private struct FinderResolver: StepCaseResolver {

        private let finder: AnyFinder?

        private let step: RoutingStep

        init<F: Finder>(finder: F, step: RoutingStep?) {
            self.step = step ?? FinderStep(finder: finder)
            self.finder = FinderBox.box(for: finder)
        }

        func resolve<D: RoutingDestination>(for destination: D) -> RoutingStep? {
            return finder?.findViewController(with: destination.context) != nil ? step : nil
        }
    }

    private var resolvers: [StepCaseResolver] = []

    /// Constructor
    public init() {

    }

    /// Adds an instance of `StepCaseResolver`
    ///
    /// - Parameter resolver: `StepCaseResolver`
    public func addCase(_ resolver: StepCaseResolver) -> Self {
        resolvers.append(resolver)
        return self
    }

    /// Adds a block that allows to write a decision case for the `Router` in the block.
    /// Returning nil from the block will mean that it not succeed.
    ///
    /// - Parameter resolverBlock: case resolver block
    public func addCase<D: RoutingDestination>(_ resolverBlock: @escaping ((_: D) -> RoutingStep?)) -> Self {
        resolvers.append(BlockResolver(resolverBlock: resolverBlock))
        return self
    }

    /// Adds a case when a view controller exist in the stack to make some particular `RoutingStep` then.
    ///
    /// - Parameters:
    ///   - finder: The `Finder` instance to find a `UIViewController` in the stack
    ///   - step: The `RoutingStep` to make if the `Finder` been able to find a view controller in the stack. If not provided,
    ///   a `UIViewController` found by the `Finder` will be considered as a view controller to start routing process from
    public func addCase<F: Finder>(when finder: F, do step: RoutingStep? = nil) -> Self {
        resolvers.append(FinderResolver(finder: finder, step: step))
        return self
    }

    /// Assembles all the cases in to a `RoutingStep` implementation
    ///
    /// - Returns: instance of a `RoutingStep`
    public func assemble() -> RoutingStep {
        return SwitcherStep(resolvers: resolvers)
    }

    /// Assembles all the cases in a `RoutingStep` instance and adds the default implementation what to do
    /// if non of the cases succeed
    ///
    /// - Parameter resolverBlock: default resolver block
    /// - Returns: an instance of RoutingStep
    public func assemble(default resolverBlock: @escaping (() -> RoutingStep)) -> RoutingStep {
        resolvers.append(BlockResolver<Any>(resolverBlock: { _ in
            return resolverBlock()
        }))
        return SwitcherStep(resolvers: resolvers)
    }

}
