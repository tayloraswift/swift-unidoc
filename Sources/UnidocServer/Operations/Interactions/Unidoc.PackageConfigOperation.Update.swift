import Symbols
import UnixTime

extension Unidoc.PackageConfigOperation
{
    enum Update
    {
        case hidden(Bool)
        case symbol(Symbol.Package)
        case expires(UnixMillisecond)
        case reset(Field)
    }
}
extension Unidoc.PackageConfigOperation.Update
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
            self = .expires(.zero)
        }
        else if
            let field:Field = .init(from: form)
        {
            self = .reset(field)
        }
        else
        {
            return nil
        }
    }
}
