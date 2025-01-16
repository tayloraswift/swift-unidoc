infix operator ~=? : ComparisonPrecedence

extension Assertion
{
    public
    struct ExpectedRangeBoundValue<Value> where Value:Comparable
    {
        public
        let allowed:ClosedRange<Value>
        public
        let value:Value

        @inlinable public
        init(allowed:ClosedRange<Value>, value:Value)
        {
            self.allowed = allowed
            self.value = value
        }
    }
}
extension Assertion.ExpectedRangeBoundValue:AssertionFailure
{
    public
    var description:String
    {
        """
        Expected value within range:
        {
            allowed: \(self.allowed.lowerBound) ... \(self.allowed.upperBound),
            sampled: \(self.value)
        }
        """
    }
}

public
func ~=? <Value>(allowed:ClosedRange<Value>,
    value:Value) -> Assertion.ExpectedRangeBoundValue<Value>?
{
    allowed ~= value ? nil : .init(allowed: allowed, value: value)
}
