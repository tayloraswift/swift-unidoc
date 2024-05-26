import HTTP
import UnidocProfiling

extension Unidoc
{
    @frozen @usableFromInline
    struct ServerTour
    {
        let started:ContinuousClock.Instant
        var metrics:ServerMetrics
        var errors:Int

        var last:[ServerMetrics.Crosstab: Request]

        var slowestQuery:SlowestQuery?

        init(started:ContinuousClock.Instant = .now)
        {
            self.started = started
            self.metrics = .init()
            self.errors = 0

            self.last = [:]

            self.slowestQuery = nil
        }
    }
}
