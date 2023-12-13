import HTTP

protocol ProceduralEndpoint:Sendable
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        request:CheckedContinuation<HTTP.ServerResponse, any Error>) async
}
