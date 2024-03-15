import BSON
import Symbols

extension Swiftinit.PackageConfigEndpoint
{
    enum Update
    {
        case hidden(Bool)
        case symbol(Symbol.Package)
        case expires(BSON.Millisecond)
    }
}
extension Swiftinit.PackageConfigEndpoint.Update
{
    init?(from form:borrowing [String: String])
    {
        if  let hidden:String = form["hidden"],
            let hidden:Bool = .init(hidden)
        {
            self = .hidden(hidden)
        }
        else if
            let symbol:Symbol.Package = form["symbol"].map(Symbol.Package.init(_:))
        {
            self = .symbol(symbol)
        }
        else if
            case "true"? = form["refresh"]
        {
            let now:BSON.Millisecond = .now()
            let later:BSON.Millisecond = .init(now.value + 10_000)

            self = .expires(later)
        }
        else
        {
            return nil
        }
    }
}
