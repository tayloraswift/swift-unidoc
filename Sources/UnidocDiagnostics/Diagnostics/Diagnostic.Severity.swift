extension Diagnostic
{
    @frozen public
    enum Severity:Equatable, Hashable, Comparable
    {
        case note
        case warning
        case error
    }
}
extension Diagnostic.Severity:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .note:     return "note"
        case .warning:  return "warning"
        case .error:    return "error"
        }
    }
}
extension Diagnostic.Severity
{
    var color:TerminalColor?
    {
        switch self
        {
        case .note:     return .rgb(150, 150, 150)
        case .warning:  return .magenta
        case .error:    return .red
        }
    }
}
