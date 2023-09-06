@frozen public
struct ServerTour
{
    public
    let started:ContinuousClock.Instant
    public
    var stats:Stats

    @inlinable public
    init(started:ContinuousClock.Instant = .now)
    {
        self.started = started
        self.stats = .init()
    }
}
