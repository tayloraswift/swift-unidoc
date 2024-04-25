import SourceDiagnostics
import UCF

extension SSGC
{
    struct AnchorResolutionError:Error
    {
        let id:UCF.AnchorMangling
        let fragment:String
        let scope:Int32?
        let notes:[Note]

        init(id:UCF.AnchorMangling, fragment:String, scope:Int32?, notes:[Note])
        {
            self.id = id
            self.fragment = fragment
            self.scope = scope
            self.notes = notes
        }
    }
}
extension SSGC.AnchorResolutionError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
    {
        if  let scope:Int32 = self.scope
        {
            output[.warning] += """
            Link fragment '\(self.fragment)' (\(self.id)) does not match any linkable anchor on
            its target page (\(output.symbolicator[scope]))
            """
        }
        else
        {
            output[.warning] += """
            Link fragment '\(self.fragment)' (\(self.id)) does not match any linkable anchor on
            its target page (unknown extension)
            """
        }
    }
}
