import Codelinks
import CodelinkResolution
import LexicalPaths
import SourceDiagnostics

extension SSGC
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
extension SSGC.RenameTargetError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    static
    func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
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

    var notes:[CodelinkResolutionError<SSGC.Symbolicator>.Note]
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
