import System

struct Snippets
{
    let list:[Snippet]

    init(list:[Snippet])
    {
        self.list = list
    }
}
extension Snippets
{
    static
    func load(from directory:String, in package:FilePath) throws -> Self
    {
        guard
        let directory:FilePath.Component = .init(directory)
        else
        {
            throw SnippetsDirectoryError.invalid(directory)
        }

        return try .load(from: package.appending(directory))
    }

    static
    func load(from path:FilePath) throws -> Self
    {
        var list:[Snippet] = []
        try path.directory.walk
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
                let snippet:Snippet = .init(location: file.path, name: $1.stem)
                list.append(snippet)
            }
        }
        return .init(list: list)
    }
}
