extension Unidoc {
    @frozen @usableFromInline enum LinkReferenceError<Vertex>: Error {
        case missing(Scalar)
    }
}
extension Unidoc.LinkReferenceError: CustomStringConvertible {
    @usableFromInline var description: String {
        switch self {
        case .missing(let id):  "Missing required vertex (\(id))"
        }
    }
}
