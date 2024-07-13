import UnidocAPI
import UnidocQueries

extension Unidoc
{
    public
    protocol Registrar<Session>:AnyObject, Sendable
    {
        associatedtype Session:RegistrarSession

        func connect<T>(with access:Unidoc.RegistrarAccessMechanisms,
            _ body:(Session) async throws -> T) async throws -> T

        func resolve(_ edition:EditionState, rebuild:Bool) async throws -> BuildLabels?
    }
}
