import ModuleGraphs

public
struct PackageRegistrationError:Error, Equatable, Sendable
{
    public
    let id:PackageIdentifier

    public
    init(id:PackageIdentifier)
    {
        self.id = id
    }
}
