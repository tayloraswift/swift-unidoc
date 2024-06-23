import PieCharts
import UnidocRecords

extension Unidoc.Stats.Coverage:Pie.ChartSource
{
    public
    typealias Key = CodingKey

    public
    var sectors:KeyValuePairs<Key, Int>
    {
        [
            .direct:        self.direct,
            .indirect:      self.indirect,
            .undocumented:  self.undocumented,
        ]
    }
}
