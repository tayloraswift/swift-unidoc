import MarkdownABI
import PackageGraphs
import System

extension SSGC
{
    /// Stores information about the source files for a package.
    struct PackageSources
    {
        var cultures:[NominalSources]
        var snippets:[LazyFile]

        var include:[FilePath]

        let root:PackageRoot?

        init(
            cultures:[NominalSources] = [],
            snippets:[LazyFile] = [],
            include:[FilePath] = [],
            root:PackageRoot? = nil)
        {
            self.cultures = cultures
            self.snippets = snippets

            self.include = include

            self.root = root
        }
    }
}
extension SSGC.PackageSources
{
    init(scanning package:borrowing PackageNode, include:consuming [FilePath] = []) throws
    {
        let root:SSGC.PackageRoot = .init(normalizing: package.root)

        self.init(include: include, root: root)

        let count:[SSGC.NominalSources.DefaultDirectory: Int] = package.modules.reduce(
            into: [:])
        {
            if  case nil = $1.location,
                let directory:SSGC.NominalSources.DefaultDirectory = .init(for: $1.type)
            {
                $0[directory, default: 0] += 1
            }
        }
        for i:Int in package.modules.indices
        {
            self.cultures.append(try .init(
                include: &self.include,
                exclude: package.exclude[i],
                package: root,
                module: package.modules[i],
                count: count))
        }

        guard
        let snippetsDirectory:FilePath.Component = .init(package.snippets)
        else
        {
            throw SSGC.SnippetDirectoryError.invalid(package.snippets)
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
                let snippet:SSGC.LazyFile = .init(location: file.path,
                    path: root.rebase(file.path),
                    name: $1.stem)

                self.snippets.append(snippet)
            }
        }
    }
}
