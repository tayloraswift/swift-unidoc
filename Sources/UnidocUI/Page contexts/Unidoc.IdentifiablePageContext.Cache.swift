import Unidoc
import UnidocDB
import UnidocRecords
import URI

extension Unidoc.IdentifiablePageContext
{
    struct Cache
    {
        var vertices:VertexCacheType
        var volumes:Unidoc.Volumes

        private
        var uris:[Unidoc.Scalar: String]

        init(vertices:VertexCacheType,
            volumes:Unidoc.Volumes,
            uris:[Unidoc.Scalar: String] = [:])
        {
            self.vertices = vertices
            self.volumes = volumes
            self.uris = uris
        }
    }
}
extension Unidoc.IdentifiablePageContext.Cache
{
    mutating
    func load(_ id:Unidoc.Scalar, by uri:(Unidoc.VolumeMetadata) -> URI?) -> Unidoc.LinkTarget?
    {
        {
            if  let target:String = $0
            {
                return .init(location: target)
            }
            else if
                let volume:Unidoc.VolumeMetadata = self.volumes[id.edition],
                let uri:URI = uri(volume)
            {
                let target:String = "\(uri)"
                $0 = target
                return .init(location: target)
            }
            else
            {
                return nil
            }
        } (&self.uris[id])
    }

    private mutating
    func load<Vertex>(_ id:Unidoc.Scalar,
        vertex:Vertex,
        principal:Bool) -> Unidoc.LinkReference<Vertex>
        where Vertex:Unidoc.PrincipalVertex
    {
        let target:Unidoc.LinkTarget? = principal ? .init(location: nil) : self.load(id)
        {
            Unidoc.DocsEndpoint[$0, vertex.route]
        }
        return .init(vertex: vertex, target: target)
    }
}
extension Unidoc.IdentifiablePageContext.Cache
{
    subscript(culture id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.CultureVertex>?
    {
        mutating get
        {
            if  case (.culture(let vertex), let principal)? = self.vertices[id]
            {
                self.load(id, vertex: vertex, principal: principal)
            }
            else
            {
                nil
            }
        }
    }

    subscript(article id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.ArticleVertex>?
    {
        mutating get
        {
            if  case (.article(let vertex), let principal)? = self.vertices[id]
            {
                self.load(id, vertex: vertex, principal: principal)
            }
            else
            {
                nil
            }
        }
    }

    subscript(decl id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.DeclVertex>?
    {
        mutating get
        {
            if  case (.decl(let vertex), let principal)? = self.vertices[id]
            {
                self.load(id, vertex: vertex, principal: principal)
            }
            else
            {
                nil
            }
        }
    }

    /// Returns the URL for the given scalar, as long as it does not point to a file.
    subscript(id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.AnyVertex>?
    {
        mutating get
        {
            self.vertices[id].map
            {
                switch $0
                {
                case (let vertex, principal: false):
                    let target:Unidoc.LinkTarget? = self.load(id)
                    {
                        switch vertex
                        {
                        case .article(let vertex):  Unidoc.DocsEndpoint[$0, vertex.route]
                        case .culture(let vertex):  Unidoc.DocsEndpoint[$0, vertex.route]
                        case .decl(let vertex):     Unidoc.DocsEndpoint[$0, vertex.route]
                        case .file:                 nil
                        case .product(let vertex):  Unidoc.DocsEndpoint[$0, vertex.route]
                        case .foreign(let vertex):  Unidoc.DocsEndpoint[$0, vertex.route]
                        case .landing:              Unidoc.DocsEndpoint[$0]
                        }
                    }

                    return .init(vertex: vertex, target: target)

                case (let vertex, principal: true):
                    return .init(vertex: vertex, target: .init(location: nil))
                }
            }
        }
    }
}
