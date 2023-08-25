import HTML
import UnidocRecords

extension HTML.Stats
{
    struct Coverage
    {
        let id:KeyPath<Record.Stats.Coverage, Int>
        let domain:String
        let weight:Int

        init(_ id:KeyPath<Record.Stats.Coverage, Int>, domain:String, weight:Int)
        {
            self.id = id
            self.domain = domain
            self.weight = weight
        }
    }
}
extension HTML.Stats.Coverage
{
    private
    var what:String
    {
        switch self.id
        {
        case \.undocumented:    return "undocumented"
        case \.indirect:        return "indirectly documented"
        case \.direct:          return "fully documented"
        default:                return "?"
        }
    }
}
extension HTML.Stats.Coverage:PieValue
{
    var `class`:String?
    {
        switch self.id
        {
        case \.undocumented:    return "coverage undocumented"
        case \.indirect:        return "coverage indirect"
        case \.direct:          return "coverage direct"
        default:                return nil
        }
    }

    func legend(_ html:inout HTML.ContentEncoder, share:Double)
    {
        html += """
        \(share.percent) \(self.what)
        """
    }

    func label(share:Double) -> String
    {
        """
        \(share.percent) of the \(self.domain) are \(self.what)
        """
    }
}
