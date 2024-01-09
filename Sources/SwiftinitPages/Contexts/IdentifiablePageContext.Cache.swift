import Unidoc
import UnidocDB
import UnidocRecords
import URI

extension IdentifiablePageContext
{
    struct Cache
    {
        var vertices:Vertices
        var volumes:Swiftinit.Volumes

        private
        var uris:[Unidoc.Scalar: String]

        init(vertices:Vertices, volumes:Swiftinit.Volumes, uris:[Unidoc.Scalar: String] = [:])
        {
            self.vertices = vertices
            self.volumes = volumes
            self.uris = uris
        }
    }
}
extension IdentifiablePageContext.Cache
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
extension IdentifiablePageContext.Cache
{
    subscript(culture scalar:Unidoc.Scalar) -> (vertex:Unidoc.CultureVertex, url:String?)?
    {
        mutating get
        {
            switch self.vertices[scalar]
            {
            case (.culture(let vertex), principal: true)?:
                (vertex, nil)
            case (.culture(let vertex), principal: false)?:
                (vertex, self.load(scalar) { Swiftinit.Docs[$0, vertex.route] })
            default:
                nil
            }
        }
    }

    subscript(article scalar:Unidoc.Scalar) -> (vertex:Unidoc.ArticleVertex, url:String?)?
    {
        mutating get
        {
            switch self.vertices[scalar]
            {
            case (.article(let vertex), principal: true)?:
                (vertex, nil)
            case (.article(let vertex), principal: false)?:
                (vertex, self.load(scalar) { Swiftinit.Docs[$0, vertex.route] })
            default:
                nil
            }
        }
    }

    subscript(decl scalar:Unidoc.Scalar) -> (vertex:Unidoc.DeclVertex, url:String?)?
    {
        mutating get
        {
            switch self.vertices[scalar]
            {
            case (.decl(let vertex), principal: true)?:
                (vertex, nil)
            case (.decl(let vertex), principal: false)?:
                (vertex, self.load(scalar) { Swiftinit.Docs[$0, vertex.route] })
            default:
                nil
            }
        }
    }

    /// Returns the URL for the given scalar, as long as it does not point to a file.
    subscript(scalar:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, url:String?)?
    {
        mutating get
        {
            self.vertices[scalar].map
            {
                switch $0
                {
                case (let vertex, principal: false):
                    let url:String? = self.load(scalar)
                    {
                        switch vertex
                        {
                        case .article(let vertex):  Swiftinit.Docs[$0, vertex.route]
                        case .culture(let vertex):  Swiftinit.Docs[$0, vertex.route]
                        case .decl(let vertex):     Swiftinit.Docs[$0, vertex.route]
                        case .file:                 nil
                        case .product(let vertex):  Swiftinit.Docs[$0, vertex.route]
                        case .foreign(let vertex):  Swiftinit.Docs[$0, vertex.route]
                        case .global:               Swiftinit.Docs[$0]
                        }
                    }

                    return (vertex, url)

                case (let vertex, principal: true):
                    return (vertex, nil)
                }
            }
        }
    }
}
