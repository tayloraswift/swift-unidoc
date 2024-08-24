@frozen public
struct DiagnosticMessages
{
    private
    var fragments:[DiagnosticFragment]

    public
    let status:DiagnosticLevel

    private
    init(fragments:[DiagnosticFragment], status:DiagnosticLevel)
    {
        self.fragments = fragments
        self.status = status
    }
}
extension DiagnosticMessages
{
    init(fragments:[DiagnosticFragment])
    {
        let status:DiagnosticLevel = fragments.reduce(into: .note)
        {
            if  case .message(let level, _) = $1
            {
                $0 = max($0, level)
            }
        }

        self.init(fragments: fragments, status: status)
    }
}
extension DiagnosticMessages:CustomStringConvertible
{
    public
    var description:String
    {
        var text:String = ""
        self.write(to: &text, colors: .disabled)
        return text
    }
}
extension DiagnosticMessages
{
    public mutating
    func demoteErrors(to level:DiagnosticLevel)
    {
        for i:Int in self.fragments.indices
        {
            {
                if  case .message(.error, let message) = $0
                {
                    $0 = .message(level, message)
                }
            } (&self.fragments[i])
        }
    }

    public
    func emit(colors:TerminalColors)
    {
        var text:String = ""
        self.write(to: &text, colors: colors)
        print(text)
    }

    private
    func write(to text:inout some TextOutputStream, colors:TerminalColors)
    {
        var first:Bool = true
        for fragment:DiagnosticFragment in self.fragments
        {
            if  first
            {
                first = false
            }
            else if case .heading = fragment
            {
                text.write("\n")
            }

            fragment.write(to: &text, colors: colors)
        }
    }
}
