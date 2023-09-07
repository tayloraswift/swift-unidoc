import ModuleGraphs

extension PackageDatabase.Packages
{
    public
    struct RegistrationError:Error, Equatable, Sendable
    {
        public
        let id:PackageIdentifier

        public
        init(id:PackageIdentifier)
        {
            self.id = id
        }
    }
}
