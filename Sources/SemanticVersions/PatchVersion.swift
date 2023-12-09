@frozen public
struct PatchVersion:VectorVersion, Equatable, Hashable, Comparable, Sendable
{
    public
    var components:Components

    @inlinable public
    init(components:Components)
    {
        self.components = components
    }
}
extension PatchVersion
{
    /// Returns a semantic version with ``Int16.max`` in the major component, and ``UInt16.max``
    /// in the less significant components.
    @inlinable public static
    var max:Self { .v(.max, .max, .max) }

    /// Creates a semantic version with the given components.
    @inlinable public static
    func v(_ major:Int16, _ minor:UInt16, _ patch:UInt16) -> Self
    {
        self.init(components: .init(major: major, minor: minor, patch: patch))
    }

    @inlinable public
    init(padding version:NumericVersion, with fill:UInt16 = 0)
    {
        switch version
        {
        case .major(let version):
            self = .v(version.number, fill, fill)
        case .minor(let version):
            self = .v(version.components.major, version.components.minor, fill)
        case .patch(let version):
            self = version
        }
    }
}
extension PatchVersion
{
    @inlinable public
    var major:MajorVersion { .v(self.components.major) }

    @inlinable public
    var minor:MinorVersion { .v(self.components.major, self.components.minor) }
}
