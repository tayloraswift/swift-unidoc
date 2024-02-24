@frozen public
struct DiagnosticMessages
{
    private
    let fragments:[DiagnosticFragment]

    init(fragments:[DiagnosticFragment])
    {
        self.fragments = fragments
    }
}
extension DiagnosticMessages
{
    public
    func emit(colors:TerminalColors)
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
                print()
            }

            print(fragment.description(colors: colors))
        }
    }
}
