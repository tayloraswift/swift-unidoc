import Symbols
import URI

extension Unidoc.PackageBuildOperation
{
    struct SymbolicParameters
    {
        let package:Symbol.Package
        let ref:String?

        private
        init(package:Symbol.Package, ref:String?)
        {
            self.package = package
            self.ref = ref
        }
    }
}
extension Unidoc.PackageBuildOperation.SymbolicParameters
{
    init?(from query:URI.Query)
    {
        var package:Symbol.Package?
        var ref:String?

        for (key, value):(String, String) in query.parameters
        {
            switch key
            {
            case "package": package = .init(value)
            case "ref":     ref = value
            default:        continue
            }
        }

        guard
        let package:Symbol.Package
        else
        {
            return nil
        }

        if  case true? = ref?.isEmpty
        {
            ref = nil
        }

        self.init(package: package, ref: ref)
    }
}
