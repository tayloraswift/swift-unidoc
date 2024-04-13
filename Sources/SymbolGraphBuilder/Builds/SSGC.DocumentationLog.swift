import SourceDiagnostics
import System

extension SSGC
{
    struct DocumentationLog
    {
        let path:FilePath
    }
}
extension SSGC.DocumentationLog
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
