public
enum SystemProcessError:Error, Equatable, Sendable
{
    case spawn(Int32, [String])
    case wait(Int32, [String])
    case exit(Int32, [String])
}
extension SystemProcessError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .spawn(let code, let invocation):
            return """
                Process posix_spawnp call failed with code \(code) \
                (\(invocation.joined(separator: " ")))
                """

        case .wait(let code, let invocation):
            return """
                Process waitpid call failed with code \(code) \
                (\(invocation.joined(separator: " ")))
                """

        case .exit(let code, let invocation):
            return """
                Process exited with code \(code) \
                (\(invocation.joined(separator: " ")))
                """
        }
    }
}
