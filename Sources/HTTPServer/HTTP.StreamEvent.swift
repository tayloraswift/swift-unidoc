extension HTTP
{
    enum StreamEvent:Sendable
    {
        case inbound(Stream)
        case quiesce
    }
}
