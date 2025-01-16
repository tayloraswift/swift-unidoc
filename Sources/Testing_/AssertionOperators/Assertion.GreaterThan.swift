infix operator >? :ComparisonPrecedence

/// Compares two elements for equality.
@inlinable public
func >? <T>(lhs:T, rhs:T) -> Assertion.ExpectedBinary<T, Assertion.GreaterThan>?
    where T:Comparable
{
    if  lhs > rhs
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
    enum GreaterThan:BinaryAssertionOperator
    {
        public
        static var symbol:String { ">" }
    }
}
