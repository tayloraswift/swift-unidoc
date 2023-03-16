import Symbols

extension TargetDependency
{
    @frozen public
    struct Product:Identifiable, Equatable, Sendable
    {
        public
        let id:ProductIdentifier
        public
        let package:PackageIdentifier
        public
        let platforms:[PlatformIdentifier]

        @inlinable public
        init(id:ProductIdentifier,
            package:PackageIdentifier,
            platforms:[PlatformIdentifier] = [])
        {
            self.id = id
            self.package = package
            self.platforms = platforms
        }
    }
}
