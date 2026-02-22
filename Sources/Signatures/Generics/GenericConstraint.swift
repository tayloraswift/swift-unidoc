@frozen public enum GenericConstraint<Scalar>: Equatable, Hashable where Scalar: Hashable {
    case `where`(_ noun: String, is: GenericOperator, to: GenericType<Scalar>)
}
extension GenericConstraint {
    @inlinable public var noun: String {
        switch self { case .where(let noun, is: _, to: _): noun }
    }
    @inlinable public var what: GenericOperator {
        switch self { case .where(_, is: let what, to: _): what }
    }
    @inlinable public var whom: GenericType<Scalar> {
        switch self { case .where(_, is: _, to: let whom): whom }
    }
}
extension GenericConstraint: Comparable where Scalar: Comparable {
    @inlinable public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.noun, lhs.what, lhs.whom) < (rhs.noun, rhs.what, rhs.whom)
    }
}
extension GenericConstraint: Sendable where Scalar: Sendable {
}
extension GenericConstraint {
    @inlinable public func map<T>(
        _ transform: (Scalar) throws -> T?
    ) rethrows -> GenericConstraint<T> {
        .where(self.noun, is: self.what, to: try self.whom.map(transform))
    }
}
