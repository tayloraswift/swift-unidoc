extension AWS.S3
{
    public
    enum RequestError:Error, Equatable, Sendable
    {
        case get(UInt)
        case put(UInt)
    }
}
