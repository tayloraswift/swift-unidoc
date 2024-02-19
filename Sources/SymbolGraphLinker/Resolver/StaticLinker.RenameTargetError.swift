import Codelinks
import CodelinkResolution
import LexicalPaths
import MarkdownLinking
import SourceDiagnostics

extension StaticLinker
{
    struct RenameTargetError:Error
    {
        let overloads:[CodelinkResolver<Int32>.Overload]
        let redirect:UnqualifiedPath
        let target:Codelink

        init(overloads:[CodelinkResolver<Int32>.Overload],
            redirect:UnqualifiedPath,
            target:Codelink)
        {
            self.overloads = overloads
            self.redirect = redirect
            self.target = target
        }
    }
}
extension StaticLinker.RenameTargetError:Diagnostic
{
    typealias Symbolicator = StaticSymbolicator

    static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        if  self.overloads.isEmpty
        {
            output[.warning] += """
            rename target '\(self.target)' for '\(self.redirect)' \
            does not refer to any known declarations
            """
        }
        else
        {
            output[.warning] += """
            rename target '\(self.target)' for '\(self.redirect)' is ambiguous
            """
        }
    }

    var notes:[InvalidCodelinkError<StaticSymbolicator>.Note]
    {
        self.overloads.map
        {
            .init(suggested: .init(
                    base: self.target.base,
                    path: self.target.path,
                    suffix: .hash($0.hash)),
                target: $0.target)
        }
    }
}
