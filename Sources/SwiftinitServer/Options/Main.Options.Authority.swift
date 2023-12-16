import HTTPServer
import NIOSSL

extension Main.Options
{
    enum Authority:String, Equatable, Hashable, Sendable
    {
        case production
        case testing
        case localhost
    }
}
extension Main.Options.Authority
{
    var type:any ServerAuthority.Type
    {
        switch self
        {
        case .localhost:    Localhost.self
        case .production:   Swiftinit.Prod.self
        case .testing:      Swiftinit.Test.self
        }
    }

    func load(certificates directory:String) throws -> any ServerAuthority
    {
        let certificates:[NIOSSLCertificate] =
            try NIOSSLCertificate.fromPEMFile("\(directory)/fullchain.pem")
        let privateKey:NIOSSLPrivateKey =
            try .init(file: "\(directory)/privkey.pem", format: .pem)

        var configuration:TLSConfiguration = .makeServerConfiguration(
            certificateChain: certificates.map(NIOSSLCertificateSource.certificate(_:)),
            privateKey: .privateKey(privateKey))

            // configuration.applicationProtocols = ["h2", "http/1.1"]
            configuration.applicationProtocols = ["h2"]

        let niossl:NIOSSLContext = try .init(configuration: configuration)

        switch self
        {
        case .localhost:    return Localhost.init(tls: niossl)
        case .production:   return Swiftinit.Prod.init(tls: niossl)
        case .testing:      return Swiftinit.Test.init(tls: niossl)
        }
    }
}
