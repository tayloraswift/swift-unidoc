import UnixTime
import UnidocDB

extension Unidoc
{
    struct MetricPaint:Sendable
    {
        let searchbot:Searchbot?
        let volume:Edition
        let shoot:Shoot
        let time:UnixAttosecond
    }
}
extension Unidoc.MetricPaint
{
    var trail:Unidoc.SearchbotTrail
    {
        .init(trunk: self.volume.package, shoot: self.shoot)
    }
}
