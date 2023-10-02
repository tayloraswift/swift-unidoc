import HTML
import Unidoc
import UnidocProfiling

extension Unidoc
{
    struct Stat:Identifiable, Sendable
    {
        let id:String

        let stratum:String
        let value:Int
        let `class`:String?

        init(_ id:String, stratum:String, value:Int, `class`:String? = nil)
        {
            self.id = id
            self.stratum = stratum
            self.value = value
            self.class = `class`
        }
    }
}
extension Unidoc.Stat:PieSector
{
    func label(share:Double) -> String
    {
        """
        \(Self.format(share: share)) percent of the \(self.stratum) are \(self.id)
        """
    }
}
