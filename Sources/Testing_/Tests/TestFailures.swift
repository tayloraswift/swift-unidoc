public
struct TestFailures:CustomStringConvertible, Error
{
    public
    let description:String

    init(description:String)
    {
        self.description = description
    }
}
