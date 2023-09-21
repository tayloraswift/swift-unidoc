import HTTPServer
import NIOSSL

extension Server.Options
{
    enum Authority:String, Equatable, Hashable, Sendable
    {
        case production
        case testing
        case localhost
    }
}
extension Server.Options.Authority
{
    var type:any ServerAuthority.Type
    {
        switch self
        {
        case .localhost:    return Localhost.self
        case .production:   return Swiftinit.self
        case .testing:      return SwiftinitTest.self
        }
    }

    func load(certificates directory:String) throws -> any ServerAuthority
    {
        let certificates:[NIOSSLCertificate] =
            try NIOSSLCertificate.fromPEMFile("\(directory)/fullchain.pem")
        let privateKey:NIOSSLPrivateKey =
            try .init(file: "\(directory)/privkey.pem", format: .pem)

        let niossl:NIOSSLContext = try .init(configuration: .makeServerConfiguration(
            certificateChain: certificates.map(NIOSSLCertificateSource.certificate(_:)),
            privateKey: .privateKey(privateKey)))

        switch self
        {
        case .localhost:    return Localhost.init(tls: niossl)
        case .production:   return Swiftinit.init(tls: niossl)
        case .testing:      return SwiftinitTest.init(tls: niossl)
        }
    }
}
