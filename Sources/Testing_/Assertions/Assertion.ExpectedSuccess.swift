extension Assertion
{
    public
    struct ExpectedSuccess
    {
        public
        let caught:any Error

        public
        init(caught:any Error)
        {
            self.caught = caught
        }
    }
}
extension Assertion.ExpectedSuccess:AssertionFailure
{
    public
    var description:String
    {
        """
        Expected success, but caught:
        ---------------------
        \(self.caught)
        """
    }
}
