import Unidoc
import UnidocDiagnostics

@frozen public
enum DroppedPassagesError:Equatable, Error
{
    case fromExtension(Unidoc.Scalar, of:Unidoc.Scalar)
}
extension DroppedPassagesError:DynamicLinkerError
{
    public
    func symbolicated(with symbolicator:DynamicSymbolicator) -> [Diagnostic]
    {
        let message:String
        switch self
        {
        case .fromExtension(_, of: let type):
            message =
            """
            dropped documentation due to coalescing multiple extensions of the same type \
            (\(symbolicator.signature(of: type)))
            """
        }

        return [.init(.warning, context: .init(), message: message)]
    }
}

