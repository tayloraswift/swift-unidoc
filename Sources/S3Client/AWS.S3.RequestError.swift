extension AWS.S3
{
    public
    enum RequestError:Error, Equatable, Sendable
    {
        case put(UInt)
    }
}
