import Atomics

//  Unchecked Sendable because ``Regex`` is apparently not ``Sendable``.
public final
class Tests:@unchecked Sendable
{
    public
    let passed:UnsafeAtomic<Int>
    public
    let failed:UnsafeAtomic<Int>

    public
    let passedAssertions:UnsafeAtomic<Int>
    public
    let failedAssertions:UnsafeAtomic<Int>

    public
    let usesTerminalColors:Bool

    public
    let filter:TestFilter

    init(useTerminalColors:Bool = true) throws
    {
        self.passed = .create(0)
        self.failed = .create(0)

        self.passedAssertions = .create(0)
        self.failedAssertions = .create(0)

        self.usesTerminalColors = useTerminalColors
        self.filter = try .init(arguments: CommandLine.arguments.dropFirst())
    }

    deinit
    {
        self.passed.destroy()
        self.failed.destroy()

        self.passedAssertions.destroy()
        self.failedAssertions.destroy()
    }
}
extension Tests
{
    public
    func context(_ path:[String]) -> TestContext?
    {
        self.filter ~= path ? .init(tests: self, path: path) : nil
    }

    public static
    func / (self:Tests, name:String) -> TestGroup?
    {
        self.context([name]).map(TestGroup.init(_:))
    }
    public static
    func ! (self:Tests, name:String) -> TestGroup
    {
        .init(.init(tests: self, path: [name]))
    }
    @_disfavoredOverload
    @available(*, deprecated)
    public static
    func / (self:Tests, name:String) -> TestGroup
    {
        self ! name
    }
}
extension Tests
{
    func bold(_ string:String, _ color:TerminalColor) -> String
    {
        self.bold(self.color(string, color))
    }
    func bold(_ string:String) -> String
    {
        self.usesTerminalColors ? "\u{1B}[1m\(string)\u{1B}[0m" : string
    }
    func color(_ string:String, _ color:TerminalColor) -> String
    {
        self.usesTerminalColors ? "\u{1B}[38;2;\(color.rawValue)m\(string)\u{1B}[39m" : string
    }

    public
    func summarize() throws
    {
        let passedAssertions:Int = self.passedAssertions.load(ordering: .relaxed)
        let passed:Int = self.passed.load(ordering: .relaxed)

        let failedAssertions:Int = self.failedAssertions.load(ordering: .relaxed)
        let failed:Int = self.failed.load(ordering: .relaxed)

        if  failed == 0, failedAssertions == 0
        {
            print(self.bold("""
                All tests passed (\(passed) test(s), \(passedAssertions) assertion(s))
                """))
        }
        else
        {
            throw TestFailures.init(description: self.bold("""
                Some tests failed (\(failed) of \(passed + failed) test(s), \
                \(failedAssertions) of \(passedAssertions + failedAssertions) assertions(s))
                """, .red))
        }
    }
}
