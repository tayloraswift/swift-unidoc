import NIOSSL

extension NIOSSLContext
{
    public
    static func serverDefault(certificateDirectory:String) throws -> Self
    {
        let privateKey:NIOSSLPrivateKey = try .init(
            file: "\(certificateDirectory)/privkey.pem",
            format: .pem)

        let fullChain:[NIOSSLCertificate] = try NIOSSLCertificate.fromPEMFile(
            "\(certificateDirectory)/fullchain.pem")

        var configuration:TLSConfiguration = .makeServerConfiguration(
            certificateChain: fullChain.map(NIOSSLCertificateSource.certificate(_:)),
            privateKey: .privateKey(privateKey))

            // configuration.applicationProtocols = ["h2", "http/1.1"]
            configuration.applicationProtocols = ["h2"]

        return try .init(configuration: configuration)
    }

    public
    static var clientDefault:Self
    {
        get throws
        {
            //  FIXME: do we need to set `http/1.1` here as well??
            var configuration:TLSConfiguration = .makeClientConfiguration()
                configuration.applicationProtocols = ["h2"]
            return try .init(configuration: configuration)
        }
    }
}
