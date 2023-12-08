import HTTPServer
import NIOSSL

extension Swiftinit
{
    struct Root
    {
        let tls:NIOSSLContext

        init(tls:NIOSSLContext)
        {
            self.tls = tls
        }
    }
}
extension Swiftinit.Root:ServerAuthority
{
    static
    var scheme:ServerScheme { .https }

    static
    var domain:String { "swiftinit.org" }

    static
    func redact(error _:any Error) -> String
    {
        "(error redacted)"
    }
}
