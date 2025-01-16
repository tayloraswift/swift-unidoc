infix operator **? :ComparisonPrecedence

/// Compares the elements of two sequences, without regards to element order.
/// Perfer this operator over ``==?(_:_:)`` for improved diagnostics.
@inlinable public
func **? <T>(
    lhs:some Sequence<T>,
    rhs:some Sequence<T>) -> Assertion.ExpectedBinary<[T], Assertion.UnorderedElementsEqual>?
    where T:Hashable
{
    let lhs:[T] = .init(lhs)
    let rhs:[T] = .init(rhs)
    if  Set<T>.init(lhs) == Set<T>.init(rhs)
    {
        return nil
    }
    else
    {
        return .init(lhs, rhs)
    }
}
extension Assertion
{
    public
    enum UnorderedElementsEqual:BinaryAssertionOperator
    {
        public
        static var symbol:String { "{==}" }
    }
}
