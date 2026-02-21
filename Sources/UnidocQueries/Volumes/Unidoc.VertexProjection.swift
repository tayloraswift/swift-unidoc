import MongoQL

extension Unidoc {
    @frozen public enum VertexProjection {
        case all
        case limited
    }
}
extension Unidoc.VertexProjection {
    var unset: [Mongo.AnyKeyPath] {
        switch self {
        case .all:
            []

        case .limited:
            [
                Unidoc.AnyVertex[.constituents],
                Unidoc.AnyVertex[.superforms],

                Unidoc.AnyVertex[.overview],
                Unidoc.AnyVertex[.details],
                Unidoc.AnyVertex[.census],
            ]
        }
    }
}
