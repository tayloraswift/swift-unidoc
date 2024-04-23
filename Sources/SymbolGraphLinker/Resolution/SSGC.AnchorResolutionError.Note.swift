import SourceDiagnostics
import UCF

extension SSGC.AnchorResolutionError
{
    struct Note
    {
        let id:UCF.AnchorMangling
        let fragment:String

        init(id:UCF.AnchorMangling, fragment:String)
        {
            self.id = id
            self.fragment = fragment
        }
    }
}
extension SSGC.AnchorResolutionError.Note:DiagnosticNote
{
    typealias Symbolicator = SSGC.Symbolicator

    static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
    {
        output[.note] = """
        available choice '\(self.fragment)' (\(self.id))
        """
    }
}
