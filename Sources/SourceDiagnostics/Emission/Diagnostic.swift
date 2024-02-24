public
protocol Diagnostic<Symbolicator>:DiagnosticNote
{
    override
    associatedtype Symbolicator:DiagnosticSymbolicator
    associatedtype Note:DiagnosticNote<Symbolicator>

    static override
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)

    var notes:[Note] { get }
}
extension Diagnostic where Note == Self
{
    @inlinable public
    var notes:[Self] { [] }
}
