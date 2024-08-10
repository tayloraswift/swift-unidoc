import UCF
import LinkResolution
import LexicalPaths
import SourceDiagnostics

extension SSGC
{
    struct RenameTargetError:Error
    {
        let overloads:[any UCF.ResolvableOverload]
        let redirect:UnqualifiedPath
        let target:UCF.Selector

        init(overloads:[any UCF.ResolvableOverload],
            redirect:UnqualifiedPath,
            target:UCF.Selector)
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

    func emit(summary output:inout DiagnosticOutput<Symbolicator>)
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

    func emit(details output:inout DiagnosticOutput<Symbolicator>)
    {
        for overload:any UCF.ResolvableOverload in self.overloads
        {
            let suggested:UCF.Selector = self.target.with(hash: overload.hash)

            output[.note] = """
            did you mean '\(suggested)'? (\(output.symbolicator.demangle(overload.id)))
            """
        }
    }
}
