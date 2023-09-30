@frozen public
struct ServerTour
{
    public
    let started:ContinuousClock.Instant
    public
    var lastUA:String?
    public
    var stats:Stats

    @inlinable public
    init(started:ContinuousClock.Instant = .now)
    {
        self.started = started
        self.lastUA = nil
        self.stats = .init()
    }
}
