import SourceDiagnostics
import System

extension SSGC
{
    @frozen public
    struct DocumentationLogger
    {
        let path:FilePath

        init(path:FilePath)
        {
            self.path = path
        }
    }
}
extension SSGC.DocumentationLogger
{
    func emit(messages:consuming DiagnosticMessages) throws
    {
        try self.path.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let text:String = "\(messages)"
            try $0.writeAll(text.utf8)
        }
    }
}
