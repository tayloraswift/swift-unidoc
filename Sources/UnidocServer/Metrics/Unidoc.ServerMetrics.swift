import ISO
import PieCharts

extension Unidoc
{
    @frozen @usableFromInline
    struct ServerMetrics:Sendable
    {
        var languages:Pie<ISO.Macrolanguage>.Accumulator
        var responses:[Crosstab: Pie<Status>.Accumulator]
        var protocols:[Crosstab: Pie<ProtocolVersion>.Accumulator]
        var requests:Pie<Origin>.Accumulator
        var transfer:Pie<Origin>.Accumulator

        init()
        {
            self.languages = .init()
            self.responses = [:]
            self.protocols = [:]
            self.requests = .init()
            self.transfer = .init()
        }
    }
}
