extension Assertion
{
    public
    struct ExpectedBinary<Value, Relation> where Relation:BinaryAssertionOperator
    {
        public
        let lhs:Value
        public
        let rhs:Value

        @inlinable public
        init(_ lhs:Value, _ rhs:Value)
        {
            self.lhs = lhs
            self.rhs = rhs
        }
    }
}
extension Assertion.ExpectedBinary:AssertionFailure
{
    public 
    var description:String
    {
        """
        Expected lhs \(Relation.symbol) rhs:
        {
            lhs: \(self.lhs),
            rhs: \(self.rhs)
        }
        """
    }
}
