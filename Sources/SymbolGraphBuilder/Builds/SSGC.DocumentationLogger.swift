import SourceDiagnostics
import System

extension SSGC
{
    @frozen public
    struct DocumentationLogger
    {
        let file:FileDescriptor?

        public
        init(file:FileDescriptor?)
        {
            self.file = file
        }
    }
}
extension SSGC.DocumentationLogger
{
    func emit(messages:consuming DiagnosticMessages) throws
    {
        guard
        let file:FileDescriptor = self.file
        else
        {
            messages.emit(colors: .enabled)
            return
        }

        let text:String = "\(messages)"
        try file.writeAll(text.utf8)
    }
}
