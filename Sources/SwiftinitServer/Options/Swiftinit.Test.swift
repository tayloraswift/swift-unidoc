import HTTPServer
import NIOSSL

extension Swiftinit
{
    struct Test
    {
        let tls:NIOSSLContext

        init(tls:NIOSSLContext)
        {
            self.tls = tls
        }
    }
}
extension Swiftinit.Test:ServerAuthority
{
    static
    var scheme:ServerScheme { .https }

    static
    var domain:String { "test.swiftinit.org" }

    static
    func redact(error _:any Error) -> String
    {
        "(error redacted)"
    }
}
