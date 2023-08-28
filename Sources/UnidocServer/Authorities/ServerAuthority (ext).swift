import HTTPServer
import NIOSSL

extension ServerAuthority where Self == SwiftinitTest
{
    static
    func swiftinitTest(_ context:NIOSSLContext) -> SwiftinitTest
    {
        .init(context: context)
    }
}
extension ServerAuthority where Self == Swiftinit
{
    static
    func swiftinit(_ context:NIOSSLContext) -> Swiftinit
    {
        .init(context: context)
    }
}
