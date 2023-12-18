import Unidoc
import UnidocDiagnostics

enum DroppedPassagesError:Equatable, Error
{
    case fromExtension(Unidoc.Group.ID, of:Unidoc.Scalar)
}
extension DroppedPassagesError:Diagnostic
{
    typealias Symbolicator = Unidoc.Symbolicator

    static
    func += (output:inout DiagnosticOutput<Unidoc.Symbolicator>, self:Self)
    {
        switch self
        {
        case .fromExtension(_, of: let type):
            output[.warning] = """
            dropped documentation due to coalescing multiple extensions of the same type \
            (\(output.symbolicator[type]))
            """
        }
    }
}