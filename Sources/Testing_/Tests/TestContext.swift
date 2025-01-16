public
struct TestContext:Sendable
{
    let tests:Tests
    let path:[String]

    init(tests:Tests, path:[String])
    {
        self.tests = tests
        self.path = path
    }
}
extension TestContext
{
    /// Creates a test group by appending the given test path component
    /// to the current path. This operator respects test filtering.
    public static
    func / (self:Self, name:String) -> TestGroup?
    {
        self.tests.context(self.path + [name]).map(TestGroup.init(_:))
    }
    /// Unconditionally creates a test group by appending the given
    /// test path component to the current path. This operator does not
    /// respect test filtering.
    public static
    func ! (self:Self, name:String) -> TestGroup
    {
        .init(.init(tests: self.tests, path: self.path + [name]))
    }
    @available(*, deprecated)
    public static
    func / (self:Self, name:String) -> TestGroup
    {
        self ! name
    }
}
extension TestContext:CustomStringConvertible
{
    public
    var description:String
    {
        self.path.joined(separator: " / ")
    }
}
