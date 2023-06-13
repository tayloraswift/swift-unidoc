import SymbolGraphs

struct GlobalContext
{
    var upstream:[Int32: LocalContext]
    let current:LocalContext

    init(upstream:[Int32: LocalContext] = [:],
        current:LocalContext)
    {
        self.upstream = upstream
        self.current = current
    }
}
extension GlobalContext
{
    subscript(package:Int32) -> LocalContext?
    {
        self.current.id == package ? self.current : self.upstream[package]
    }
    subscript(scalar address:GlobalAddress) -> SymbolGraph.Scalar?
    {
        self[address.package]?[scalar: address]?.scalar
    }

    func expand(_ address:GlobalAddress) -> [GlobalAddress]
    {
        var current:GlobalAddress = address
        var path:[GlobalAddress] = [current]
        //  This prevents us from getting stuck in an infinite loop if one of the
        //  documentation archives is malformed/malicious.
        var seen:Set<GlobalAddress> = [current]

        while   let next:GlobalAddress = self[current.package]?.scope(of: current),
                case nil = seen.update(with: next)
        {
            path.append(next)
            current = next
        }

        return path.reversed()
    }
}
