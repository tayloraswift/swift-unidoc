infix operator !=? :ComparisonPrecedence

/// Compares two elements for equality.
@inlinable public
func !=? <T>(lhs:T, rhs:T) -> Assertion.ExpectedBinary<T, Assertion.NotEqual>?
    where T:Equatable
{
    if  lhs != rhs
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
    enum NotEqual:BinaryAssertionOperator
    {
        public
        static var symbol:String { "!=" }
    }
}
