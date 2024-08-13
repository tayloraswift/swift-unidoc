public
protocol Diagnostic<Symbolicator>
{
    associatedtype Symbolicator:DiagnosticSymbolicator

    func emit(summary:inout DiagnosticOutput<Symbolicator>)
    func emit(details:inout DiagnosticOutput<Symbolicator>)
}
extension Diagnostic
{
    @inlinable public
    func emit(details:inout DiagnosticOutput<Symbolicator>)
    {
    }
}
