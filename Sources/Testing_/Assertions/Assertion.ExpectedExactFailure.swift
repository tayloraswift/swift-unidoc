extension Assertion
{
    public
    struct ExpectedExactFailure<Failure> where Failure:Error & Equatable
    {
        public
        let expected:Failure

        public
        let caught:(any Error)?

        public
        init(caught:(any Error)?, expected:Failure)
        {
            self.caught = caught
            self.expected = expected
        }
    }
}
extension Assertion.ExpectedExactFailure:AssertionFailure
{
    public
    var description:String
    {
        if  let caught:any Error = self.caught
        {
            return """
            Expected error with exact value:
            ---------------------
            \(self.expected)
            ---------------------
            But caught:
            ---------------------
            \(caught)
            """
        }
        else
        {
            return """
            Expected error with exact value:
            ---------------------
            \(self.expected)
            """
        }
    }
}
