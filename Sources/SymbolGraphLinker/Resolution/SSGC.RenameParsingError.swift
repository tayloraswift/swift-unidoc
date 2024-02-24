import LexicalPaths
import SourceDiagnostics

extension SSGC
{
    struct RenameParsingError:Error, Equatable
    {
        let redirect:UnqualifiedPath
        let target:String

        init(redirect:UnqualifiedPath, target:String)
        {
            self.redirect = redirect
            self.target = target
        }
    }
}
extension SSGC.RenameParsingError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    static
    func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
    {
        output[.warning] += """
        rename target '\(self.target)' for '\(self.redirect)' could not be parsed
        """
    }
}
