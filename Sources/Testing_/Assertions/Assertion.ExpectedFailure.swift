extension Assertion
{
    public
    struct ExpectedFailure<Expected> where Expected:Error
    {
        public
        let caught:(any Error)?

        public
        init(caught:(any Error)?)
        {
            self.caught = caught
        }
    }
}
extension Assertion.ExpectedFailure:AssertionFailure
{
    public
    var description:String
    {
        if let caught:any Error = self.caught
        {
            return """
            Expected error of type \(String.init(reflecting: Expected.self)), but caught:
            ---------------------
            \(caught)
            """
        }
        else
        {
            return """
            Expected error of type \(String.init(reflecting: Expected.self))
            """
        }
    }
}
