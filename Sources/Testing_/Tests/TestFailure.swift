public
struct TestFailure
{
    public
    let location:Assertion

    public
    let failure:any AssertionFailure
    public
    init(_ failure:any AssertionFailure, location:Assertion)
    {
        self.location = location
        self.failure = failure
    }
}
