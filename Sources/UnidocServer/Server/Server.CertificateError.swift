extension Server
{
    enum CertificateError:Error, Sendable
    {
        case directoryRequired
    }
}
