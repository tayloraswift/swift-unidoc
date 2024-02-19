import SourceDiagnostics

extension SSGC.SupplementBindingError
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
extension SSGC.SupplementBindingError.Note:DiagnosticNote
{
    typealias Symbolicator = SSGC.Symbolicator

    static
    func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
    {
        output[.note] = """
        did you mean to reference the protocol witness? \
        (\(output.symbolicator[self.suggested]))
        """
    }
}
