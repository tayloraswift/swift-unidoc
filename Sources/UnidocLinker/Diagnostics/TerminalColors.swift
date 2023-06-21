@frozen public
enum TerminalColors
{
    case enabled
    case disabled
}
extension TerminalColors
{
    private
    var enabled:Bool { self == .enabled }
}
extension TerminalColors
{
    func bold(_ string:String, _ color:TerminalColor?) -> String
    {
        self.bold(self.color(string, color))
    }
    func bold(_ string:String) -> String
    {
        self.enabled ? "\u{1B}[1m\(string)\u{1B}[0m" : string
    }
    func color(_ string:String, _ color:TerminalColor?) -> String
    {
        self.enabled ? color.map { "\u{1B}[\($0)m\(string)\u{1B}[39m" } ?? string : string
    }
}
