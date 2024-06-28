extension Unidoc.BuildCoordinator
{
    enum Event:Sendable
    {
        case submit(UInt, Subscription)
        case cancel(UInt)
        case notify(Notification)
    }
}
