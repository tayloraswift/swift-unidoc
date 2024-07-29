import UCF
import SourceDiagnostics

extension UCF.OverloadResolutionError
{
    @frozen public
    struct Note
    {
        public
        let suggested:UCF.Selector
        public
        let target:UCF.Overload<Symbolicator.Address>.Target

        @inlinable public
        init(suggested:UCF.Selector,
            target:UCF.Overload<Symbolicator.Address>.Target)
        {
            self.suggested = suggested
            self.target = target
        }
    }
}
extension UCF.OverloadResolutionError.Note:DiagnosticNote
{
    @inlinable public static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
    {
        switch self.target
        {
        case    .scalar(let scalar),
                .vector(let scalar, self: _):
            output[.note] = """
            did you mean '\(self.suggested)'? (\(output.symbolicator[scalar]))
            """
        }
    }
}
