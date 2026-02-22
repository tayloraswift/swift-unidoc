extension Unidoc {
    @frozen public enum SurfaceDelta: Equatable, Sendable {
        /// The uplink affected a historical version.
        case ignoredHistorical
        /// The uplink affected a private package.
        case ignoredPrivate
        /// The uplink changed the API surface of an **existing release version** of an existing
        /// package. It should be extremely rare for the payload to be non-nil.
        case ignoredRepeated(SitemapDelta?)
        /// The uplink introduces a brand new API surface; no release documentation had
        /// previously been published for the associated package.
        case initial
        /// The uplink changed the API surface of an existing package by replacing it with the
        /// API surface of a **new release version**.
        case replaced(SitemapDelta?)
    }
}
