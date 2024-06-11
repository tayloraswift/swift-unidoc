extension Unidoc
{
    @frozen public
    enum SurfaceDelta:Equatable, Sendable
    {
        /// The uplink introduces a brand new API surface; no release documentation had
        /// previously been published for the associated package.
        case initial
        /// The uplink did not affect any publicly-relevant package or volume. For example, the
        /// package may be hidden, or the uplink might have been for a historical version.
        case ignored
        /// The uplink changed the API surface of an **existing release version** of an existing
        /// package. It should be extremely rare for the payload to be non-nil.
        case changed(SitemapDelta?)
        /// The uplink changed the API surface of an existing package by replacing it with the
        /// API surface of a **new release version**.
        case updated(SitemapDelta?)
    }
}
