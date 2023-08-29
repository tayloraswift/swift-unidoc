import ModuleGraphs

extension Volume
{
    @frozen public
    struct Selector:Equatable, Hashable, Sendable
    {
        public
        var package:PackageIdentifier
        public
        var version:Substring?

        @inlinable public
        init(package:PackageIdentifier, version:Substring?)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Volume.Selector
{
    public
    init(_ trunk:String)
    {
        if  let colon:String.Index = trunk.firstIndex(of: ":")
        {
            self.init(
                package: .init(trunk[..<colon]),
                version: trunk[trunk.index(after: colon)...])
        }
        else
        {
            self.init(
                package: .init(trunk),
                version: nil)
        }
    }
}