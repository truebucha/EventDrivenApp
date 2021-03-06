//
//  Middleware.swift
//  ReactiveReSwift
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2016 Charlotte Tortorella. All rights reserved.
//

/**
 Middleware is a structure that allows you to modify, filter out and dispatch more
 actions, before the action being handled reaches the store.
 */
public struct Middleware<State> {
    public typealias DispatchFunction = (Action...) -> Void
    public typealias GetState = () -> State

    internal let transform: (GetState, @escaping DispatchFunction, Action) -> [Action]

    /// Create a blank slate Middleware.
    public init() {
        self.transform = { [$2] }
    }

    /**
     Initialises the middleware with a transformative function.
     
     - parameter transform: The function that will be able to modify passed actions.
     */
    internal init(_ transform: @escaping (GetState, @escaping DispatchFunction, Action) -> [Action]) {
        self.transform = transform
    }

    /**
     Initialises the middleware by concatenating the transformative functions from
     the middleware that was passed in.
     */
    public init(_ first: Middleware<State>, _ rest: Middleware<State>...) {
        self = rest.reduce(first) {
            $0.concat($1)
        }
    }

    /// Safe encapsulation of side effects guaranteed not to affect the action being passed through the middleware.
    public func sideEffect(_ effect: @escaping (GetState, @escaping DispatchFunction, Action) -> Void) -> Middleware<State> {
        return Middleware<State> { getState, dispatch, action in
            self.transform(getState, dispatch, action).map {
                effect(getState, dispatch, $0)
                return $0
            }
        }
    }

    /// Concatenates the transform function of the passed `Middleware` onto the callee's transform.
    public func concat(_ other: Middleware<State>) -> Middleware<State> {
        return Middleware<State> { getState, dispatch, action in
            self.transform(getState, dispatch, action).flatMap {
                other.transform(getState, dispatch, $0)
            }
        }
    }

    /// Transform the action into another action.
    public func map(_ transform: @escaping (GetState, Action) -> Action) -> Middleware<State> {
        return Middleware<State> { getState, dispatch, action in
            self.transform(getState, dispatch, action).map {
                transform(getState, $0)
            }
        }
    }

    @available(*, renamed: "flatMap(_:)")
    /// One to many pattern allowing one action to be turned into multiple.
    public func increase(_ transform: @escaping (GetState, Action) -> [Action]) -> Middleware<State> {
        return flatMap(transform)
    }

    /// One to many pattern allowing one action to be turned into multiple.
    public func flatMap(_ transform: @escaping (GetState, Action) -> [Action]) -> Middleware<State> {
        return Middleware<State> { getState, dispatch, action in
            self.transform(getState, dispatch, action).flatMap {
                transform(getState, $0)
            }
        }
    }

    /// Filters while mapping actions to new actions.
    public func flatMap(_ transform: @escaping (GetState, Action) -> Action?) -> Middleware<State> {
        return Middleware<State> { getState, dispatch, action in
            self.transform(getState, dispatch, action).flatMap {
                transform(getState, $0)
            }
        }
    }

    /// Drop the action iff `isIncluded(action) != true`.
    public func filter(_ isIncluded: @escaping (GetState, Action) -> Bool) -> Middleware<State> {
        return Middleware<State> { getState, dispatch, action in
            self.transform(getState, dispatch, action).filter {
                isIncluded(getState, $0)
            }
        }
    }
}
