import Unidoc
import UnidocDB
import UnidocRecords
import URI

struct InlinerCache
{
    var vertices:Vertices
    var names:Names

    private
    var uris:[Unidoc.Scalar: String]

    init(vertices:Vertices, names:Names, uris:[Unidoc.Scalar: String] = [:])
    {
        self.vertices = vertices
        self.names = names
        self.uris = uris
    }
}
extension InlinerCache
{
    private mutating
    func load(_ scalar:Unidoc.Scalar, by uri:(Volume.Names) -> URI?) -> String?
    {
        {
            if  let target:String = $0
            {
                return target
            }
            else if
                let names:Volume.Names = self.names[scalar.zone],
                let uri:URI = uri(names)
            {
                let target:String = "\(uri)"
                $0 = target
                return target
            }
            else
            {
                return nil
            }
        } (&self.uris[scalar])
    }
}
extension InlinerCache
{
    subscript(article scalar:Unidoc.Scalar) -> (master:Volume.Vertex.Article, url:String?)?
    {
        mutating get
        {
            if  case .article(let master)? = self.vertices[scalar]
            {
                return (master, self.load(scalar) { Site.Docs[$0, master.shoot] })
            }
            else
            {
                return nil
            }
        }
    }

    subscript(culture scalar:Unidoc.Scalar) -> (master:Volume.Vertex.Culture, url:String?)?
    {
        mutating get
        {
            if  case .culture(let master)? = self.vertices[scalar]
            {
                return (master, self.load(scalar) { Site.Docs[$0, master.shoot] })
            }
            else
            {
                return nil
            }
        }
    }

    subscript(decl scalar:Unidoc.Scalar) -> (master:Volume.Vertex.Decl, url:String?)?
    {
        mutating get
        {
            if  case .decl(let master)? = self.vertices[scalar]
            {
                return (master, self.load(scalar) { Site.Docs[$0, master.shoot] })
            }
            else
            {
                return nil
            }
        }
    }

    /// Returns the URL for the given scalar, as long as it does not point to a file.
    subscript(scalar:Unidoc.Scalar) -> (master:Volume.Vertex, url:String?)?
    {
        mutating get
        {
            self.vertices[scalar].map
            {
                (master:Volume.Vertex) in

                let url:String? = self.load(scalar)
                {
                    switch master
                    {
                    case .article(let article): return Site.Docs[$0, article.shoot]
                    case .culture(let culture): return Site.Docs[$0, culture.shoot]
                    case .decl(let decl):       return Site.Docs[$0, decl.shoot]
                    case .file:                 return nil
                    case .meta:                 return Site.Docs[$0]
                    }
                }

                return (master, url)
            }
        }
    }
}
