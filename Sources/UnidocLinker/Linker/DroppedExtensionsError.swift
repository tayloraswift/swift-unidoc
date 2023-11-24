import Symbols
import UnidocDiagnostics

@frozen public
struct DroppedExtensionsError:Equatable, Error
{
    public
    let affected:AffectedExtensions
    public
    let count:Int

    @inlinable internal
    init(affected:AffectedExtensions, count:Int)
    {
        self.affected = affected
        self.count = count
    }
}
extension DroppedExtensionsError
{
    @inlinable public static
    func extending(_ namespace:Symbol.Module, count:Int) -> Self
    {
        .init(affected: .namespace(namespace), count: count)
    }

    @inlinable public static
    func extending(_ decl:Symbol.Decl, count:Int) -> Self
    {
        .init(affected: .decl(decl), count: count)
    }
}
extension DroppedExtensionsError:Diagnostic
{
    public
    typealias Symbolicator = DynamicSymbolicator

    @inlinable public static
    func += (output:inout DiagnosticOutput<DynamicSymbolicator>, self:Self)
    {
        switch self.affected
        {
        case .decl(let decl):
            output[.warning] = """
            dropped \(self.count) extension(s) because the type they extend \
            (\(output.symbolicator.demangle(decl))) could not be loaded
            """

        case .namespace(let namespace):
            output[.warning] = """
            dropped \(self.count) extension(s) because the namespace they extend \
            (\(namespace)) could not be loaded
            """
        }
    }
}
