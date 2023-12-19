import Unidoc
import UnidocDB
import UnidocRecords
import URI

extension IdentifiablePageContext
{
    struct Cache
    {
        var vertices:Vertices
        var volumes:Volumes

        private
        var uris:[Unidoc.Scalar: String]

        init(vertices:Vertices, volumes:Volumes, uris:[Unidoc.Scalar: String] = [:])
        {
            self.vertices = vertices
            self.volumes = volumes
            self.uris = uris
        }
    }
}
extension IdentifiablePageContext.Cache where ID:VersionedPageIdentifier
{
    mutating
    func load(_ scalar:Unidoc.Scalar, by uri:(Unidoc.VolumeMetadata) -> URI?) -> String?
    {
        {
            if  let target:String = $0
            {
                return target
            }
            else if
                let volume:Unidoc.VolumeMetadata = self.volumes[scalar.edition],
                let uri:URI = uri(volume)
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
extension IdentifiablePageContext.Cache where ID:VersionedPageIdentifier
{
    subscript(culture scalar:Unidoc.Scalar) -> (vertex:Unidoc.Vertex.Culture, url:String?)?
    {
        mutating get
        {
            if  case .culture(let vertex)? = self.vertices[scalar]
            {
                (vertex, self.load(scalar) { Swiftinit.Docs[$0, vertex.shoot] })
            }
            else
            {
                nil
            }
        }
    }

    subscript(article scalar:Unidoc.Scalar) -> (vertex:Unidoc.Vertex.Article, url:String?)?
    {
        mutating get
        {
            if  case .article(let vertex)? = self.vertices[scalar]
            {
                (vertex, self.load(scalar) { Swiftinit.Docs[$0, vertex.shoot] })
            }
            else
            {
                nil
            }
        }
    }

    subscript(decl scalar:Unidoc.Scalar) -> (vertex:Unidoc.Vertex.Decl, url:String?)?
    {
        mutating get
        {
            if  case .decl(let vertex)? = self.vertices[scalar]
            {
                (vertex, self.load(scalar) { Swiftinit.Docs[$0, vertex.shoot] })
            }
            else
            {
                nil
            }
        }
    }

    /// Returns the URL for the given scalar, as long as it does not point to a file.
    subscript(scalar:Unidoc.Scalar) -> (vertex:Unidoc.Vertex, url:String?)?
    {
        mutating get
        {
            self.vertices[scalar].map
            {
                (vertex:Unidoc.Vertex) in

                let url:String? = self.load(scalar)
                {
                    switch vertex
                    {
                    case .article(let vertex):  Swiftinit.Docs[$0, vertex.shoot]
                    case .culture(let vertex):  Swiftinit.Docs[$0, vertex.shoot]
                    case .decl(let vertex):     Swiftinit.Docs[$0, vertex.shoot]
                    case .file:                 nil
                    case .product(let vertex):  Swiftinit.Docs[$0, vertex.shoot]
                    case .foreign(let vertex):  Swiftinit.Docs[$0, vertex.shoot]
                    case .global:               Swiftinit.Docs[$0]
                    }
                }

                return (vertex, url)
            }
        }
    }
}
