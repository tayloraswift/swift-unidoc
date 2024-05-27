extension Symbol
{
    @frozen public
    struct Edition:Equatable, Hashable, Sendable
    {
        public
        var package:Package
        /// A name corresponding to a git ref.
        public
        var ref:String

        @inlinable public
        init(package:Package, ref:String)
        {
            self.package = package
            self.ref = ref
        }
    }
}
extension Symbol.Edition:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.package)/\(self.ref)" }
}
extension Symbol.Edition:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        if  let slash:String.Index = description.firstIndex(of: "/")
        {
            self.init(
                package: .init(description[..<slash]),
                ref: .init(description[description.index(after: slash)...]))
        }
        else
        {
            return nil
        }
    }
}
