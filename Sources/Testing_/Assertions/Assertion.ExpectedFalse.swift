extension Assertion
{
    public
    struct ExpectedFalse
    {
        public
        init()
        {
        }
    }
}
extension Assertion.ExpectedFalse:AssertionFailure
{
    public 
    var description:String
    {
        "Expected false."
    }
}
