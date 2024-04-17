import UnidocProfiling

extension ServerProfile.ByClient
{
    subscript(annotation:Unidoc.ClientAnnotation) -> Int
    {
        _read
        {
            yield  self[keyPath: annotation.field]
        }
        _modify
        {
            yield &self[keyPath: annotation.field]
        }
    }
}
