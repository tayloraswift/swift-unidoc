extension Symbol
{
    @frozen public
    struct PackageAtRef:Equatable, Hashable, Sendable
    {
        public
        var package:Package
        public
        var ref:Substring?

        @inlinable public
        init(package:Package, ref:Substring?)
        {
            self.package = package
            self.ref = ref
        }
    }
}
extension Symbol.PackageAtRef:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.ref.map { "\(self.package)/\($0)" } ?? "\(self.package)"
    }
}
extension Symbol.PackageAtRef:LosslessStringConvertible
{
    public
    init(_ trunk:String)
    {
        if  let slash:String.Index = trunk.firstIndex(of: "/")
        {
            self.init(package: .init(trunk[..<slash]),
                ref: trunk[trunk.index(after: slash)...])
        }
        else
        {
            self.init(package: .init(trunk), ref: nil)
        }
    }
}
