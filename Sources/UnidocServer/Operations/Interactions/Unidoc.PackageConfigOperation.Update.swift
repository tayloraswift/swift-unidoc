import BSON
import Symbols

extension Unidoc.PackageConfigOperation
{
    enum Update
    {
        case hidden(Bool)
        case symbol(Symbol.Package)
        case expires(BSON.Millisecond)
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
            let already:BSON.Millisecond = .init(0)
            self = .expires(already)
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
