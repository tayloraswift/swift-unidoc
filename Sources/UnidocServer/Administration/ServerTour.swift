import HTTP
import UnidocProfiling

@frozen @usableFromInline
struct ServerTour
{
    let started:ContinuousClock.Instant
    var profile:ServerProfile
    var errors:Int

    var lastImpression:Request?
    var lastSearchbot:Request?
    var lastRequest:Request?

    var slowestQuery:SlowestQuery?

    init(started:ContinuousClock.Instant = .now)
    {
        self.started = started
        self.profile = .init()
        self.errors = 0

        self.lastImpression = nil
        self.lastSearchbot = nil
        self.lastRequest = nil

        self.slowestQuery = nil
    }
}
