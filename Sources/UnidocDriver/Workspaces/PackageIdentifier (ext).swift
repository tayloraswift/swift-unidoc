import ModuleGraphs

extension PackageIdentifier
{
    static
    func infer(from url:String) -> Self?
    {
        for component:Substring in url.split(separator: "/").reversed()
        {
            let names:[Substring] = component.split(separator: ".",
                omittingEmptySubsequences: false)
            if  let basename:Substring = names.first, !basename.isEmpty
            {
                return .init(basename)
            }
        }
        return nil
    }
}
