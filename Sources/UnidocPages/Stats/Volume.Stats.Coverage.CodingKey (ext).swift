import UnidocProfiling
import UnidocRecords

extension Unidoc.Stats.Coverage.CodingKey:Identifiable
{
    public
    var id:String
    {
        switch self
        {
        case .direct:       "direct"
        case .indirect:     "indirect"
        case .undocumented: "undocumented"
        }
    }
}
extension Unidoc.Stats.Coverage.CodingKey:PieSectorKey
{
    public
    var name:String
    {
        switch self
        {
        case .direct:       "fully documented"
        case .indirect:     "indirectly documented"
        case .undocumented: "completely undocumented"
        }
    }
}
