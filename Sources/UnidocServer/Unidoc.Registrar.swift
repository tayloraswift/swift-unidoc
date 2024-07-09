extension Unidoc
{
    public
    protocol Registrar<Session>:AnyObject, Sendable
    {
        associatedtype Session:RegistrarSession

        func connect<T>(with context:ServerPluginContext,
            _ body:(Session) async throws -> T) async throws -> T
    }
}
