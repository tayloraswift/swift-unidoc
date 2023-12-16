extension DiagnosticMessage
{
    @frozen public
    enum Severity:Equatable, Hashable, Comparable
    {
        case note
        case warning
        case error
    }
}
extension DiagnosticMessage.Severity:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .note:     "note"
        case .warning:  "warning"
        case .error:    "error"
        }
    }
}
extension DiagnosticMessage.Severity
{
    var color:TerminalColor?
    {
        switch self
        {
        case .note:     .rgb(150, 150, 150)
        case .warning:  .magenta
        case .error:    .red
        }
    }
}
