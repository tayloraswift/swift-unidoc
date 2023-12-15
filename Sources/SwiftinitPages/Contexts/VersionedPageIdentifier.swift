import Unidoc

protocol VersionedPageIdentifier
{
    static
    func != (self:Self, id:Unidoc.Scalar) -> Bool
}
