import Unidoc
import UnidocRecords
import URI

struct InlinerCache
{
    private
    var targets:[Unidoc.Scalar: String]

    var masters:Masters
    var zones:Zones

    init(targets:[Unidoc.Scalar: String] = [:], masters:Masters, zones:Zones)
    {
        self.targets = targets
        self.masters = masters
        self.zones = zones
    }
}
extension InlinerCache
{
    private mutating
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
extension InlinerCache
{
    subscript(article scalar:Unidoc.Scalar) -> (master:Record.Master.Article, uri:String?)?
    {
        mutating get
        {
            if  case .article(let master)? = self.masters[scalar]
            {
                return (master, self.load(scalar) { .init(article: master, in: $0) })
            }
            else
            {
                return nil
            }
        }
    }

    subscript(culture scalar:Unidoc.Scalar) -> (master:Record.Master.Culture, uri:String?)?
    {
        mutating get
        {
            if  case .culture(let master)? = self.masters[scalar]
            {
                return (master, self.load(scalar) { .init(culture: master, in: $0) })
            }
            else
            {
                return nil
            }
        }
    }

    subscript(decl scalar:Unidoc.Scalar) -> (master:Record.Master.Decl, uri:String?)?
    {
        mutating get
        {
            if  case .decl(let master)? = self.masters[scalar]
            {
                return (master, self.load(scalar) { .init(decl: master, in: $0) })
            }
            else
            {
                return nil
            }
        }
    }

    subscript(scalar:Unidoc.Scalar) -> (master:Record.Master, uri:String?)?
    {
        mutating get
        {
            self.masters[scalar].map
            {
                (master:Record.Master) in
                (master, self.load(scalar) { .init(master: master, in: $0) })
            }
        }
    }
}
