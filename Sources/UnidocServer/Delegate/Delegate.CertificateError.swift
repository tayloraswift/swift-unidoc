extension Delegate
{
    enum CertificateError:Error, Sendable
    {
        case directoryRequired
    }
}
