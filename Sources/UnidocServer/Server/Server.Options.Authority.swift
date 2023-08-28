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
        case .production:   return Swiftinit.self
        case .testing:      return SwiftinitTest.self
        case .localhost:    return Localhost.self
        }
    }

    func load(certificates:String?) throws -> any ServerAuthority
    {
        func context() throws -> NIOSSLContext
        {
            guard let directory:String = certificates
            else
            {
                throw Server.CertificateError.directoryRequired
            }

            let certificates:[NIOSSLCertificate] =
                try NIOSSLCertificate.fromPEMFile("\(directory)/fullchain.pem")
            let privateKey:NIOSSLPrivateKey =
                try .init(file: "\(directory)/privkey.pem", format: .pem)

            return try .init(configuration: .makeServerConfiguration(
                certificateChain: certificates.map(NIOSSLCertificateSource.certificate(_:)),
                privateKey: .privateKey(privateKey)))
        }

        switch self
        {
        case .production:   return .swiftinit(try context())
        case .testing:      return .swiftinitTest(try context())
        case .localhost:    return .localhost
        }
    }
}
