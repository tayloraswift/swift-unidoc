import PackageGraphs
import System

extension SPM
{
    /// Stores information about the source files for a package.
    struct PackageSources
    {
        var cultures:[NominalSources]
        var snippets:[SnippetSources]

        private
        init(cultures:[NominalSources] = [], snippets:[SnippetSources] = [])
        {
            self.cultures = cultures
            self.snippets = snippets
        }
    }
}
extension SPM.PackageSources
{
    init(scanning package:borrowing PackageNode, snippetsDirectory:String? = nil) throws
    {
        let root:FilePath = .init(package.root.path)

        self.init()

        for i:Int in package.modules.indices
        {
            self.cultures.append(try .init(
                scanning: package.modules[i],
                exclude: package.exclude[i],
                root: root))
        }

        guard
        let snippetsDirectory:String
        else
        {
            return
        }

        guard
        let snippetsDirectory:FilePath.Component = .init(snippetsDirectory)
        else
        {
            throw SPM.SnippetDirectoryError.invalid(snippetsDirectory)
        }

        let snippets:FilePath = root.appending(snippetsDirectory)
        try snippets.directory.walk
        {
            let file:(path:FilePath, extension:String)

            if  let `extension`:String = $1.extension
            {
                file.extension = `extension`
                file.path = $0 / $1
            }
            else
            {
                //  directory, or some extensionless file we don’t care about
                return
            }

            if  file.extension == "swift"
            {
                let snippet:SPM.SnippetSources = .init(location: file.path, name: $1.stem)
                self.snippets.append(snippet)
            }
        }
    }
}

extension SPM.PackageSources
{
    func yield(include:inout [FilePath])
    {
        for module:SPM.NominalSources in self.cultures
        {
            include += module.include
        }
    }
}
