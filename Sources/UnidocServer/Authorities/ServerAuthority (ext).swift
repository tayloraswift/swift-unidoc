import HTTPServer
import NIOSSL

extension ServerAuthority where Self == Swiftinit
{
    static
    func swiftinit(_ context:NIOSSLContext) -> Swiftinit
    {
        .init(context: context)
    }
}
