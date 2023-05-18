import NIOHTTP1
import TraceableErrors

public
protocol ServerAuthority<SecurityContext>
{
    associatedtype SecurityContext = Never

    static
    var scheme:ServerScheme { get }
    static
    var domain:String { get }

    var tls:SecurityContext? { get }

    static
    func redact(error:any Error) -> String
}

extension ServerAuthority where Self == Localhost
{
    @inlinable public static
    var localhost:Self { .init() }
}

extension ServerAuthority<Never>
{
    @inlinable public
    var tls:SecurityContext? { nil }
    /// Dumps detailed information about the caught error. This information will be
    /// shown to *anyone* accessing the server. In production, you must override
    /// this default implementation to avoid undermining site security.
    public static
    func redact(error:any Error) -> String
    {
        var notes:[String] = []
        var next:any Error = error
        while true
        {
            switch next
            {
            case let current as any TraceableError:
                notes.append(contentsOf: current.notes)
                next = current.underlying

            case let last:
                var description:String = last.headline(plaintext: true)
                for note:String in notes.reversed()
                {
                    description += "\nNote: \(note)"
                }
                return description
            }
        }
    }
}
extension ServerAuthority
{
    /// Formats a URL from the given URI. The URI should begin with a slash.
    static
    func url(_ uri:String) -> String
    {
        switch self.scheme
        {
        case .http(port: 80):           return "http://\(self.domain)\(uri)"
        case .http(port: let port):     return "http://\(self.domain):\(port)\(uri)"
        case .https(port: 443):         return "https://\(self.domain)\(uri)"
        case .https(port: let port):    return "https://\(self.domain):\(port)\(uri)"
        }
    }
    static
    func link(_ uri:String, rel:ServerResource.Relationship) -> String
    {
        "<\(Self.url(uri))>; rel=\"\(rel)\""
    }
}
