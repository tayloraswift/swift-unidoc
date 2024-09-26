import Symbols
import UnixTime
import URI

extension Unidoc.PackageConfigOperation
{
    enum Update
    {
        case hidden(Bool)
        case symbol(Symbol.Package)
        case expires(UnixMillisecond)
    }
}
extension Unidoc.PackageConfigOperation.Update:URI.QueryDecodable
{
    init?(parameters:borrowing [String: String])
    {
        if  let hidden:String = parameters["hidden"],
            let hidden:Bool = .init(hidden)
        {
            self = .hidden(hidden)
        }
        else if
            let symbol:Symbol.Package = parameters["symbol"].map(Symbol.Package.init(_:))
        {
            self = .symbol(symbol)
        }
        else if
            case "true"? = parameters["refresh"]
        {
            self = .expires(.zero)
        }
        else
        {
            return nil
        }
    }
}
