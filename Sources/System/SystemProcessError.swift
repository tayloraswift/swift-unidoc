public
enum SystemProcessError:Error, Equatable, Sendable
{
    case spawn(Int32, [String])
    case wait(Int32, [String])
    case exit(Int32, [String])
}
