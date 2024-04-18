import BSON
import SymbolGraphs
import Symbols

extension Unidoc.PackageConfigOperation
{
    enum Update
    {
        case hidden(Bool)
        case platformPreference(Triple)
        case symbol(Symbol.Package)
        case expires(BSON.Millisecond)
        case build(Unidoc.BuildRequest?)
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
            let triple:String = form["platform-preference"],
            let triple:Triple = .init(triple)
        {
            self = .platformPreference(triple)
        }
        else if
            let symbol:Symbol.Package = form["symbol"].map(Symbol.Package.init(_:))
        {
            self = .symbol(symbol)
        }
        else if
            case "true"? = form["refresh"]
        {
            //  Right now there is an artificial one second delay to mitigate spam, but it’s not
            //  clear to me if this is actually beneficial.
            let now:BSON.Millisecond = .now()
            let later:BSON.Millisecond = .init(now.value + 1_000)

            self = .expires(later)
        }
        else if
            case "rebuild" = form["build"]
        {
            self = .build(.auto)
        }
        else if
            case "cancel" = form["build"]
        {
            self = .build(nil)
        }
        else
        {
            return nil
        }
    }
}