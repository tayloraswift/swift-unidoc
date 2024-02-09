import LexicalPaths
import UnidocDiagnostics

extension StaticLinker
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
extension StaticLinker.RenameParsingError:Diagnostic
{
    typealias Symbolicator = StaticSymbolicator

    static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        output[.warning] += """
        rename target '\(self.target)' for '\(self.redirect)' could not be parsed
        """
    }
}
