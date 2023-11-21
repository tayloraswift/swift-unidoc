import UnidocProfiling
import UnidocRecords

extension Volume.Stats.Coverage:PieValues
{
    public
    typealias SectorKey = CodingKey

    public
    var sectors:KeyValuePairs<SectorKey, Int>
    {
        [
            .direct:        self.direct,
            .indirect:      self.indirect,
            .undocumented:  self.undocumented,
        ]
    }
}
