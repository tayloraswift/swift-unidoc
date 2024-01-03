import Unidoc

extension Swiftinit
{
    typealias VertexPageIdentifier = _SwiftinitVertexPageIdentifier
}

/// The name of this protocol is ``Swiftinit.VertexPageIdentifier``.
protocol _SwiftinitVertexPageIdentifier
{
    static
    func != (self:Self, id:Unidoc.Scalar) -> Bool
}
