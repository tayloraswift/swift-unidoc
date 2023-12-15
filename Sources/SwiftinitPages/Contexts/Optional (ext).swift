import Unidoc

extension Never?:VersionedPageIdentifier
{
    static
    func != (self:Self, id:Unidoc.Scalar) -> Bool
    {
        true
    }
}
