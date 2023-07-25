import ModuleGraphs
import Symbols
import UnidocDiagnostics

@frozen public
enum DroppedExtensionsError:Equatable, Error
{
    case extensions(of:Symbol.Decl, count:Int)
    case decls(of:ModuleIdentifier, count:Int)
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
        switch self
        {
        case .extensions(of: let extendee, count: let count):
            return """
            dropped \(count) extension(s) because the type they extend \
            (\(symbolicator.signature(of: extendee))) could not be loaded
            """

        case .decls(of: let namespace, count: let count):
            return """
            dropped \(count) declarations(s) because the namespace they extend \
            (\(namespace)) could not be loaded
            """
        }
    }
}
