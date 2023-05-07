import TraceableErrors

public
struct SystemCommandError:Error, Sendable
{
    public
    let underlying:any Error
    public
    let invocation:[String]

    public
    init(underlying:any Error, invocation:[String])
    {
        self.underlying = underlying
        self.invocation = invocation
    }
}
extension SystemCommandError
{
    init(_ error:SystemProcessError, invocation:[String])
    {
        self.init(underlying: error, invocation: invocation)
    }
}
extension SystemCommandError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.invocation == rhs.invocation && lhs.underlying == rhs.underlying
    }
}
extension SystemCommandError:TraceableError
{
    public
    var notes:[String]
    {
        ["While executing command: \(self.invocation.joined(separator: " "))"]
    }
}
