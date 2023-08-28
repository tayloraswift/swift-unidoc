import Unidoc
import UnidocRecords
import URI

struct InlinerCache
{
    var masters:Masters
    var names:Names

    private
    var urls:[Unidoc.Scalar: String]

    init(masters:Masters, names:Names, urls:[Unidoc.Scalar: String] = [:])
    {
        self.masters = masters
        self.names = names
        self.urls = urls
    }
}
extension InlinerCache
{
    private mutating
    func load(_ scalar:Unidoc.Scalar, by url:(Volume.Names) -> URL?) -> String?
    {
        {
            if  let target:String = $0
            {
                return target
            }
            else if
                let names:Volume.Names = self.names[scalar.zone],
                let url:URL = url(names)
            {
                let target:String = "\(url)"
                $0 = target
                return target
            }
            else
            {
                return nil
            }
        } (&self.urls[scalar])
    }
}
extension InlinerCache
{
    subscript(article scalar:Unidoc.Scalar) -> (master:Volume.Master.Article, url:String?)?
    {
        mutating get
        {
            if  case .article(let master)? = self.masters[scalar]
            {
                return (master, self.load(scalar) { .relative(Site.Docs[$0, master.shoot]) })
            }
            else
            {
                return nil
            }
        }
    }

    subscript(culture scalar:Unidoc.Scalar) -> (master:Volume.Master.Culture, url:String?)?
    {
        mutating get
        {
            if  case .culture(let master)? = self.masters[scalar]
            {
                return (master, self.load(scalar) { .relative(Site.Docs[$0, master.shoot]) })
            }
            else
            {
                return nil
            }
        }
    }

    subscript(decl scalar:Unidoc.Scalar) -> (master:Volume.Master.Decl, url:String?)?
    {
        mutating get
        {
            if  case .decl(let master)? = self.masters[scalar]
            {
                return (master, self.load(scalar) { .relative(Site.Docs[$0, master.shoot]) })
            }
            else
            {
                return nil
            }
        }
    }

    subscript(file scalar:Unidoc.Scalar,
        line line:Int? = nil) -> (master:Volume.Master.File, url:String?)?
    {
        mutating get
        {
            if  case .file(let master)? = self.masters[scalar],
                let url:String = self.load(scalar,
                    by: { $0.github(blob: master.symbol).map(URL.absolute(_:)) })
            {
                //  Need to append the line fragment here and not in
                //  ``Volume.Names.url(github:)`` because the cache should
                //  support multiple line fragments for the same file.
                return (master, line.map { "\(url)#L\($0 + 1)" } ?? url)
            }
            else
            {
                return nil
            }
        }
    }

    subscript(scalar:Unidoc.Scalar) -> (master:Volume.Master, url:String?)?
    {
        mutating get
        {
            self.masters[scalar].map
            {
                (master:Volume.Master) in
                (master, self.load(scalar) { .init(master: master, in: $0) })
            }
        }
    }
}
