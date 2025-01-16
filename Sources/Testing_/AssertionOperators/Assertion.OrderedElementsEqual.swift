infix operator ..? :ComparisonPrecedence

/// Compares the elements of two sequences, enforcing ordering.
/// Perfer this operator over ``==?(_:_:)`` for improved diagnostics.
@inlinable public
func ..? <T>(
    lhs:some Sequence<T>,
    rhs:some Sequence<T>) -> Assertion.ExpectedBinary<[T], Assertion.OrderedElementsEqual>?
    where T:Equatable
{
    let lhs:[T] = .init(lhs)
    let rhs:[T] = .init(rhs)
    if  lhs.elementsEqual(rhs) 
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
    enum OrderedElementsEqual:BinaryAssertionOperator
    {
        public
        static var symbol:String { "==" }
    }
}
