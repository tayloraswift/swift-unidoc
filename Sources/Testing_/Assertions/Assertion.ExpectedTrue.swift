extension Assertion
{
    public
    struct ExpectedTrue
    {
        public
        init()
        {
        }
    }
}
extension Assertion.ExpectedTrue:AssertionFailure
{
    public 
    var description:String
    {
        "Expected true."
    }
}
