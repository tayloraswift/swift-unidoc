import ModuleGraphs

extension Database.Package
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
