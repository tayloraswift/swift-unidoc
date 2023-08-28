import HTTPServer
import NIOSSL

struct SwiftinitTest
{
    private
    let context:NIOSSLContext

    init(context:NIOSSLContext)
    {
        self.context = context
    }
}
extension SwiftinitTest:ServerAuthority
{
    static
    var scheme:ServerScheme { .https }

    static
    var domain:String { "test.swiftinit.org" }

    var tls:NIOSSLContext? { self.context }

    static
    func redact(error _:any Error) -> String
    {
        "(error redacted)"
    }
}
