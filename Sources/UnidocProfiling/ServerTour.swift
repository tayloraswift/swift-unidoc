import HTTP

@frozen public
struct ServerTour
{
    public
    let started:ContinuousClock.Instant
    public
    var profile:ServerProfile

    public
    var lastImpression:Request?
    public
    var lastSearchbot:Request?
    public
    var lastRequest:Request?

    public
    var slowestQuery:SlowestQuery?

    @inlinable public
    init(started:ContinuousClock.Instant = .now)
    {
        self.started = started
        self.profile = .init()

        self.lastImpression = nil
        self.lastSearchbot = nil
        self.lastRequest = nil

        self.slowestQuery = nil
    }
}
