extension Assertion
{
    public
    struct ExpectedNil<Wrapped>
    {
        public
        let value:Wrapped

        public
        init(unwrapped value:Wrapped)
        {
            self.value = value
        }
    }
}
extension Assertion.ExpectedNil:AssertionFailure
{
    public 
    var description:String
    {
        "Expected nil optional of type \(Wrapped.self)?, but unwrapped \(self.value)."
    }
}
