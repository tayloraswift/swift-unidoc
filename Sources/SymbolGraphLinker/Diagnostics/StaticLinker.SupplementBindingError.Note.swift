import UnidocDiagnostics

extension StaticLinker.SupplementBindingError
{
    struct Note
    {
        let suggested:Int32

        init(suggested:Int32)
        {
            self.suggested = suggested
        }
    }
}
extension StaticLinker.SupplementBindingError.Note:DiagnosticNote
{
    typealias Symbolicator = StaticSymbolicator

    static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        output[.note] = """
        did you mean to reference the protocol witness? \
        (\(output.symbolicator.signature(of: self.suggested)))
        """
    }
}
