extension Unidoc.PackageIndexOperation
{
    enum Subject
    {
        case repo(owner:String, name:String, private:Bool)
        case ref(Unidoc.Package, ref:String)
    }
}
extension Unidoc.PackageIndexOperation.Subject
{
    init?(from form:borrowing [String: String])
    {
        if  let owner:String = form["owner"],
            let repo:String = form["repo"]
        {
            guard Self.validate(owner), Self.validate(repo)
            else
            {
                return nil
            }

            self = .repo(owner: owner, name: repo, private: form["private"] == "true")
        }
        else if
            let package:String = form["package"],
            let package:Unidoc.Package = .init(package),
            let ref:String = form["ref"]
        {
            guard Self.validate(ref)
            else
            {
                return nil
            }

            self = .ref(package, ref: ref)
        }
        else
        {
            return nil
        }
    }

    /// Returns true if the identifier contains illegal characters.
    private static
    func validate(_ identifier:String) -> Bool
    {
        identifier.allSatisfy
        {
            switch $0
            {
            case "\"":  false
            case "\\":  false
            default:    true
            }
        }
    }
}
