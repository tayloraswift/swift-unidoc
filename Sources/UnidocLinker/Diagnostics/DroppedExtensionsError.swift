import ModuleGraphs
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
    @inlinable public
    static func extending(_ namespace:ModuleIdentifier, count:Int) -> Self
    {
        .init(affected: .namespace(namespace), count: count)
    }

    @inlinable public
    static func extending(_ decl:Symbol.Decl, count:Int) -> Self
    {
        .init(affected: .decl(decl), count: count)
    }
}
extension DroppedExtensionsError:DynamicLinkerError
{
    public
    func symbolicated(with symbolicator:DynamicSymbolicator) -> [Diagnostic]
    {
        [
            .init(.warning, context: .init(), message: self.message(symbolicator: symbolicator))
        ]
    }

    private
    func message(symbolicator:DynamicSymbolicator) -> String
    {
        switch self.affected
        {
        case .decl(let decl):
            return """
            dropped \(self.count) extension(s) because the type they extend \
            (\(symbolicator.signature(of: decl))) could not be loaded
            """

        case .namespace(let namespace):
            return """
            dropped \(self.count) extension(s) because the namespace they extend \
            (\(namespace)) could not be loaded
            """
        }
    }
}
