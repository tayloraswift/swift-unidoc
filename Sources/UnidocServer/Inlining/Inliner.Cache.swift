import Unidoc
import UnidocRecords
import URI

extension Inliner
{
    struct Cache
    {
        private
        var targets:[Unidoc.Scalar: String]
        var zones:Zones

        init(targets:[Unidoc.Scalar: String] = [:], zones:Zones)
        {
            self.targets = targets
            self.zones = zones
        }
    }
}
extension Inliner.Cache
{
    mutating
    func load(_ scalar:Unidoc.Scalar, by uri:(Record.Zone.Names) -> URI?) -> String?
    {
        {
            if  let target:String = $0
            {
                return target
            }
            else if
                let zone:Record.Zone.Names = self.zones[scalar.zone],
                let uri:URI = uri(zone)
            {
                let target:String = "\(uri)"
                $0 = target
                return target
            }
            else
            {
                return nil
            }
        } (&self.targets[scalar])
    }
}
extension Inliner.Cache
{
    subscript(scalar:Unidoc.Scalar, article:Record.Master.Article) -> String?
    {
        mutating get
        {
            self.load(scalar) { .init(article: article, in: $0) }
        }
    }
    subscript(scalar:Unidoc.Scalar, culture:Record.Master.Culture) -> String?
    {
        mutating get
        {
            self.load(scalar) { .init(culture: culture, in: $0) }
        }
    }
    subscript(scalar:Unidoc.Scalar, master:Record.Master.Decl) -> String?
    {
        mutating get
        {
            self.load(scalar) { .init(decl: master, in: $0) }
        }
    }
}
extension Inliner.Cache
{
    subscript(scalar:Unidoc.Scalar, master:Record.Master) -> String?
    {
        mutating get
        {
            self.load(scalar) { .init(master: master, in: $0) }
        }
    }
}
