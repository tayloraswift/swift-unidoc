@frozen public
struct ServerTour
{
    public
    let started:ContinuousClock.Instant
    public
    var profile:ServerProfile
    public
    var last:ServerProfile.Sample
    public
    var lastImpression:ServerProfile.Sample

    @inlinable public
    init(started:ContinuousClock.Instant = .now)
    {
        self.started = started
        self.profile = .init()

        self.last = .init()
        self.lastImpression = .init()
    }
}