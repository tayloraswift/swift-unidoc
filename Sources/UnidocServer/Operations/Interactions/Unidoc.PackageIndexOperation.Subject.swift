import URI

extension Unidoc.PackageIndexOperation {
    enum Subject {
        case repo(owner: String, name: String, githubInstallation: Int32?)
        case ref(Unidoc.Package, ref: String)
    }
}
extension Unidoc.PackageIndexOperation.Subject: URI.QueryDecodable {
    init?(parameters: borrowing [String: String]) {
        if  let owner: String = parameters["owner"],
            let repo: String = parameters["repo"] {
            guard Self.validate(owner), Self.validate(repo) else {
                return nil
            }

            let githubInstallation: Int32? = parameters["installation"].flatMap(Int32.init(_:))

            self = .repo(owner: owner, name: repo, githubInstallation: githubInstallation)
        } else if
            let package: String = parameters["package"],
            let package: Unidoc.Package = .init(package),
            let ref: String = parameters["ref"] {
            guard Self.validate(ref) else {
                return nil
            }

            self = .ref(package, ref: ref)
        } else {
            return nil
        }
    }

    /// Returns true if the identifier contains illegal characters.
    private static func validate(_ identifier: String) -> Bool {
        identifier.allSatisfy {
            switch $0 {
            case "\"":  false
            case "\\":  false
            default:    true
            }
        }
    }
}
