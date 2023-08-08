import HTTPServer
import NIOSSL

extension Delegate.Options
{
    enum Authority:String, Equatable, Hashable, Sendable
    {
        case localhost
        case testing
    }
}
extension Delegate.Options.Authority
{
    var type:any ServerAuthority.Type
    {
        switch self
        {
        case .localhost:    return Localhost.self
        case .testing:      return Swiftinit.self
        }
    }

    func load(certificates:String?) throws -> any ServerAuthority
    {
        switch self
        {
        case .localhost:
            return .localhost

        case .testing:
            guard let directory:String = certificates
            else
            {
                throw Delegate.CertificateError.directoryRequired
            }

            let certificates:[NIOSSLCertificate] =
                try NIOSSLCertificate.fromPEMFile("\(directory)/fullchain.pem")
            let privateKey:NIOSSLPrivateKey =
                try .init(file: "\(directory)/privkey.pem", format: .pem)

            let context:NIOSSLContext = try .init(configuration: .makeServerConfiguration(
                certificateChain: certificates.map(NIOSSLCertificateSource.certificate(_:)),
                privateKey: .privateKey(privateKey)))

            return .swiftinit(context)
        }
    }
}
