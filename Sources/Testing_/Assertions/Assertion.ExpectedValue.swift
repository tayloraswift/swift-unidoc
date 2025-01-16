extension Assertion
{
    public
    struct ExpectedValue<Wrapped>
    {
        public
        init()
        {
        }
    }
}
extension Assertion.ExpectedValue:AssertionFailure
{
    public 
    var description:String
    {
        "Expected non-nil value of type \(Wrapped.self)."
    }
}
