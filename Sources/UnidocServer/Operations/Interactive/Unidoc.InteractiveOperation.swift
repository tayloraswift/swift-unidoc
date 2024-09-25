import HTTP
import UnidocRender

extension Unidoc
{
    public
    protocol InteractiveOperation:Sendable
    {
        /// DO NOT REPLACE `__consuming` with `consuming`, it will be miscompiled due to
        /// https://github.com/apple/swift/issues/70133
        __consuming
        func load(with context:ServerResponseContext) async throws -> HTTP.ServerResponse?
    }
}
