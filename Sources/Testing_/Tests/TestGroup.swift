infix operator !

public final
class TestGroup
{
    public
    let context:TestContext

    public private(set)
    var passed:Int
    public private(set)
    var failed:[TestFailure]

    init(_ context:TestContext)
    {
        self.context = context

        self.passed = 0
        self.failed = []
    }

    deinit
    {
        guard self.count != 0
        else
        {
            return
        }

        self.context.tests.passedAssertions.wrappingIncrement(by: self.passed,
            ordering: .relaxed)
        self.context.tests.failedAssertions.wrappingIncrement(by: self.failed.count,
            ordering: .relaxed)

        self.failed.isEmpty ?
            self.context.tests.passed.wrappingIncrement(ordering: .relaxed) :
            self.context.tests.failed.wrappingIncrement(ordering: .relaxed)

        print(self.description)
    }
}
extension TestGroup?
{
    public static
    func / (self:TestGroup?, name:String) -> TestGroup?
    {
        self.flatMap { $0 / name }
    }
}
extension TestGroup
{
    /// The total number of assertions checked by this test group so far.
    public
    var count:Int
    {
        self.passed + self.failed.count
    }

    /// Creates a test group by appending the given test path component
    /// to the current path. This operator respects test filtering.
    public static
    func / (self:TestGroup, name:String) -> TestGroup?
    {
        self.context / name
    }
    /// Unconditionally creates a test group by appending the given
    /// test path component to the current path. This operator does not
    /// respect test filtering.
    public static
    func ! (self:TestGroup, name:String) -> TestGroup
    {
        self.context ! name
    }
    @_disfavoredOverload
    @available(*, deprecated)
    public static
    func / (self:TestGroup, name:String) -> TestGroup
    {
        self.context ! name
    }
}
extension TestGroup:CustomStringConvertible
{
    public
    var description:String
    {
        var description:String
        if self.failed.isEmpty
        {
            description =
            """
            \(self.context.description): \
            \(self.context.tests.bold("passed", .green)) \
            (\(self.passed) assertion(s))
            """
        }
        else
        {
            description =
            """
            \(self.context.tests.bold(self.context.description)): \
            \(self.context.tests.bold("failed", .red)) \
            (\(self.failed.count) of \(self.count) assertions(s))))
            """
        }

        for (number, test):(Int, TestFailure) in self.failed.enumerated()
        {
            let assertion:Assertion = test.location

            description +=
            """

            [\(self.context.tests.bold(number.description))]: \
            Assertion at \(self.context.tests.bold("\(assertion.file):\(assertion.line)")) \
            (in \(assertion.function)) failed:
            \(test.failure)
            """
        }

        return description
    }
}
extension TestGroup
{
    @discardableResult
    public
    func `do`<Success>(
        function:String = #function,
        file:String = #fileID,
        line:Int = #line,
        _ body:() throws -> Success) -> Success?
    {
        do
        {
            let result:Success = try body()
            self.passed += 1
            return result
        }
        catch let error
        {
            self.failed.append(.init(Assertion.ExpectedSuccess.init(caught: error),
                location: .init(
                    function: function,
                    path: self.context.path,
                    file: file,
                    line: line)))
            return nil
        }
    }
    public
    func `do`<Failure>(catching expected:Failure.Type,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line,
        _ body:() throws -> ())
        where Failure:Error
    {
        let failure:Assertion.ExpectedFailure<Failure>
        do
        {
            try body()
            failure = .init(caught: nil)
        }
        catch is Failure
        {
            self.passed += 1
            return
        }
        catch let other
        {
            failure = .init(caught: other)
        }

        self.failed.append(.init(failure,
            location: .init(
                function: function,
                path: self.context.path,
                file: file,
                line: line)))
    }
    public
    func `do`<Failure>(catching exact:Failure,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line,
        _ body:() throws -> ())
        where Failure:Error & Equatable
    {
        let failure:Assertion.ExpectedExactFailure<Failure>
        do
        {
            try body()
            failure = .init(caught: nil, expected: exact)
        }
        catch exact as Failure
        {
            self.passed += 1
            return
        }
        catch let other
        {
            failure = .init(caught: other, expected: exact)
        }

        self.failed.append(.init(failure,
            location: .init(
                function: function,
                path: self.context.path,
                file: file,
                line: line)))
    }
}

extension TestGroup
{
    @discardableResult
    public
    func `do`<Success>(
        function:String = #function,
        file:String = #fileID,
        line:Int = #line,
        _ body:() async throws -> Success) async -> Success?
    {
        do
        {
            let result:Success = try await body()
            self.passed += 1
            return result
        }
        catch let error
        {
            self.failed.append(.init(Assertion.ExpectedSuccess.init(caught: error),
                location: .init(
                    function: function,
                    path: self.context.path,
                    file: file,
                    line: line)))
            return nil
        }
    }
    public
    func `do`<Failure>(catching expected:Failure.Type,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line,
        _ body:() async throws -> ()) async
        where Failure:Error
    {
        let failure:Assertion.ExpectedFailure<Failure>
        do
        {
            try await body()
            failure = .init(caught: nil)
        }
        catch is Failure
        {
            self.passed += 1
            return
        }
        catch let other
        {
            failure = .init(caught: other)
        }

        self.failed.append(.init(failure,
            location: .init(
                function: function,
                path: self.context.path,
                file: file,
                line: line)))
    }
    public
    func `do`<Failure>(catching exact:Failure,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line,
        _ body:() async throws -> ()) async
        where Failure:Error & Equatable
    {
        let failure:Assertion.ExpectedExactFailure<Failure>
        do
        {
            try await body()
            failure = .init(caught: nil, expected: exact)
        }
        catch exact as Failure
        {
            self.passed += 1
            return
        }
        catch let other
        {
            failure = .init(caught: other, expected: exact)
        }

        self.failed.append(.init(failure,
            location: .init(
                function: function,
                path: self.context.path,
                file: file,
                line: line)))
    }
}

extension TestGroup
{
    @discardableResult
    public
    func expect(true bool:Bool,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line) -> Bool
    {
        if  bool
        {
            self.passed += 1
            return true
        }
        else
        {
            self.failed.append(.init(Assertion.ExpectedTrue.init(),
                location: .init(
                    function: function,
                    path: self.context.path,
                    file: file,
                    line: line)))
            return false
        }
    }
    @discardableResult
    public
    func expect(false bool:Bool,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line) -> Bool
    {
        if  bool
        {
            self.failed.append(.init(Assertion.ExpectedFalse.init(),
                location: .init(
                    function: function,
                    path: self.context.path,
                    file: file,
                    line: line)))
            return false
        }
        else
        {
            self.passed += 1
            return true
        }
    }

    @discardableResult
    public
    func expect<Expectation>(_ failure:Expectation?,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line) -> Bool
        where Expectation:AssertionFailure
    {
        if let failure:Expectation = failure
        {
            self.failed.append(.init(failure,
                location: .init(
                    function: function,
                    path: self.context.path,
                    file: file,
                    line: line)))
            return false
        }
        else
        {
            self.passed += 1
            return true
        }
    }
    @discardableResult
    public
    func expect<Wrapped>(value optional:Wrapped?,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line) -> Wrapped?
    {
        if  let value:Wrapped = optional
        {
            self.passed += 1
            return value
        }
        else
        {
            self.failed.append(.init(Assertion.ExpectedValue<Wrapped>.init(),
                location: .init(
                    function: function,
                    path: self.context.path,
                    file: file,
                    line: line)))
            return nil
        }
    }
    @discardableResult
    public
    func expect<Wrapped>(nil optional:Wrapped?,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line) -> Bool
    {
        if  let value:Wrapped = optional
        {
            self.failed.append(.init(Assertion.ExpectedNil<Wrapped>.init(
                    unwrapped: value),
                location: .init(
                    function: function,
                    path: self.context.path,
                    file: file,
                    line: line)))
            return false
        }
        else
        {
            self.passed += 1
            return true
        }
    }
}
