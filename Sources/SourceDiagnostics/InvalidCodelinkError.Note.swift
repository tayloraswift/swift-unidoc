import CodelinkResolution
import Codelinks

extension InvalidCodelinkError
{
    /// TODO: this doesn’t belong in this module.
    @frozen public
    struct Note
    {
        public
        let suggested:Codelink
        public
        let target:CodelinkResolver<Symbolicator.Address>.Overload.Target

        @inlinable public
        init(suggested:Codelink,
            target:CodelinkResolver<Symbolicator.Address>.Overload.Target)
        {
            self.suggested = suggested
            self.target = target
        }
    }
}
extension InvalidCodelinkError.Note:DiagnosticNote
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
