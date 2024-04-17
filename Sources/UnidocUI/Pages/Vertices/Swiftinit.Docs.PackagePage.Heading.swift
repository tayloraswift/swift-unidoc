import HTML

extension Swiftinit.Docs.PackagePage
{
    enum Heading
    {
        case repository
        case dependencies
        case platforms
        case snapshot
    }
}
extension Swiftinit.Docs.PackagePage.Heading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .repository:   "ss:package-repository"
        case .dependencies: "ss:package-dependencies"
        case .platforms:    "ss:platform-requirements"
        case .snapshot:     "ss:snapshot-information"
        }
    }
}
extension Swiftinit.Docs.PackagePage.Heading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .repository:   "Package repository"
        case .dependencies: "Package dependencies"
        case .platforms:    "Platform requirements"
        case .snapshot:     "Snapshot information"
        }
    }
}
