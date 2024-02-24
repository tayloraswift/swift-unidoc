public
protocol DiagnosticNote<Symbolicator>
{
    associatedtype Symbolicator:DiagnosticSymbolicator

    static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
}
