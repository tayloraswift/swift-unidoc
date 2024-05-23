extension Unidoc.GraphStateLoop
{
    struct Subscriber
    {
        let subscription:Subscription
        let continuation:CheckedContinuation<SubscriberEvent, any Error>
    }
}
