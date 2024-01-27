extension Main
{
    @frozen public
    enum OptionsError:Error, Equatable, Sendable
    {
        case invalidMongoReplicaSetSeed
        case invalidAuthority(String?)
        case invalidBucketName(String?)
        case invalidCertificateDirectory
        case invalidPort(String?)
        case unrecognized(String)
    }
}
