import Symbols

extension Unidoc
{
    @frozen public
    struct EditionSelector:Equatable, Hashable, Sendable
    {
        public
        var package:Symbol.Package
        public
        var ref:Substring?

        @inlinable public
        init(package:Symbol.Package, ref:Substring?)
        {
            self.package = package
            self.ref = ref
        }
    }
}
extension Unidoc.EditionSelector:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.ref.map { "\(self.package)/\($0)" } ?? "\(self.package)"
    }
}
extension Unidoc.EditionSelector:LosslessStringConvertible
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
