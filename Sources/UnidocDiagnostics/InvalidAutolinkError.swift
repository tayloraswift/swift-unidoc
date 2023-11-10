@frozen public
struct InvalidAutolinkError<Symbolicator>:Equatable, Error
    where Symbolicator:DiagnosticSymbolicator
{
    public
    let expression:String

    @inlinable public
    init(expression:String)
    {
        self.expression = expression
    }
}
extension InvalidAutolinkError:Diagnostic
{
    @inlinable public static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
    {
        output[.warning] += """
        autolink expression '\(self.expression)' could not be parsed
        """
    }
}
