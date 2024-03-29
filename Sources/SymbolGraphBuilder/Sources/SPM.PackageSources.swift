import MarkdownABI
import PackageGraphs
import System

extension SPM
{
    /// Stores information about the source files for a package.
    struct PackageSources
    {
        var cultures:[NominalSources]
        var snippets:[ResourceFile]

        var include:[FilePath]

        let root:SPM.PackageRoot?

        init(
            cultures:[NominalSources] = [],
            snippets:[ResourceFile] = [],
            include:[FilePath] = [],
            root:SPM.PackageRoot? = nil)
        {
            self.cultures = cultures
            self.snippets = snippets

            self.include = include

            self.root = root
        }
    }
}
extension SPM.PackageSources
{
    init(scanning package:borrowing PackageNode, include:consuming [FilePath] = []) throws
    {
        let root:SPM.PackageRoot = .init(normalizing: package.root)

        self.init(include: include, root: root)

        for i:Int in package.modules.indices
        {
            self.cultures.append(try .init(
                include: &self.include,
                exclude: package.exclude[i],
                package: root,
                module: package.modules[i]))
        }

        guard
        let snippetsDirectory:FilePath.Component = .init(package.snippets)
        else
        {
            throw SPM.SnippetDirectoryError.invalid(package.snippets)
        }

        let snippets:FilePath = root.path.appending(snippetsDirectory)
        if !snippets.directory.exists()
        {
            return
        }

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
                //  Should we be mangling URL-unsafe characters?
                let snippet:SPM.ResourceFile = .init(location: file.path,
                    path: root.rebase(file.path),
                    name: $1.stem)

                self.snippets.append(snippet)
            }
        }
    }
}
