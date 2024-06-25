import UnidocRecords
import UnidocRender
import URI

extension Unidoc
{
    /// Vertex layers are a way of segregating documentation orthogonally to the normal
    /// hierarchy. Although they are visible to users, their true purpose is signal to search
    /// engines what pages to index and what pages to ignore. Vertex layers are **not**
    /// namespaces; all vertex layers are interchangable, some of them are merely non-canonical.
    /// This enables us to reclassify pages without disrupting users.
    public
    protocol VertexLayer
    {
        /// The primary layer, which is visible to search engines. The **s** used to stand for
        /// *Swift*, but now it’s just part of the plural.
        static
        var docs:ServerRoot { get }
        /// The detail layer, which is hidden from search engines. The **c** stands for *C* (and
        /// later C++). It has no relation to DocC.
        static
        var docc:ServerRoot { get }
        /// The archive layer, which is hidden from search engines. Historical documentation is not
        /// segregated into primary and detail layers, because it is all considered supplementary.
        static
        var hist:ServerRoot { get }
    }
}
extension Unidoc.VertexLayer
{
    private static
    subscript(volume:Unidoc.VolumeSelector, cdecl cdecl:Bool) -> URI
    {
        if  case _? = volume.version
        {
            Self.hist / "\(volume)"
        }
        else if cdecl
        {
            Self.docc / "\(volume)"
        }
        else
        {
            Self.docs / "\(volume)"
        }
    }

    static
    subscript(volume:Unidoc.VolumeMetadata, route:Unidoc.Route) -> URI
    {
        var uri:URI = Self[volume.selector, cdecl: route.cdecl]

        uri.path += route.stem
        uri["hash"] = route.hash?.description

        return uri
    }

    static
    subscript(volume:Unidoc.VolumeMetadata) -> URI
    {
        Self[volume.selector, cdecl: false]
    }
}
