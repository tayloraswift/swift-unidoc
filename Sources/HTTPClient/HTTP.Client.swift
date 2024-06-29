extension HTTP
{
    public
    protocol Client:Identifiable, Sendable
    {
        associatedtype Connection:ClientConnection

        /// Connect to the ``remote`` host and perform the given operation.
        func connect<T>(port:Int, with body:(Connection) async throws -> T) async throws -> T

        var remote:String { get }
    }
}
extension HTTP.Client
{
    /// Returns the ``remote`` hostname.
    @inlinable public
    var id:String { self.remote }
}
