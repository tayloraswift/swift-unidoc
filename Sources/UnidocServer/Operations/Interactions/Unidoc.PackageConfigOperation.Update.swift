import BSON
import Symbols

extension Unidoc.PackageConfigOperation
{
    enum Update
    {
        case hidden(Bool)
        case symbol(Symbol.Package)
        case expires(BSON.Millisecond)
        case build(Unidoc.BuildRequest?)

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
            case "request"? = form["build"]
        {
            //  TODO: stop re-parsing the package id here, it is so stupid!
            if  let version:String = form["version"],
                let version:Unidoc.Version = .init(version),
                let package:String = form["package"],
                let package:Unidoc.Package = .init(package)
            {
                self = .build(.id(.init(package: package, version: version)))
                return
            }

            let force:Bool = form["force"] == "true"

            if  case "prerelease"? = form["series"]
            {
                self = .build(.latest(.prerelease, force: force))
            }
            else
            {
                self = .build(.latest(.release, force: force))
            }
        }
        else if
            case "cancel"? = form["build"]
        {
            self = .build(nil)
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
