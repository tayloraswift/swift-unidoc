import UnixTime
import UnidocDB

extension Unidoc
{
    struct MetricPaint:Sendable
    {
        let searchbot:Searchbot?
        let volume:Edition
        let vertex:VertexPath
        let time:UnixAttosecond
    }
}

