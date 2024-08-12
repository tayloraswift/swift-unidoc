import SourceDiagnostics
import System

extension SSGC
{
    @frozen public
    struct Logger
    {
        let ignoreErrors:Bool
        let file:FileDescriptor?

        public
        init(ignoreErrors:Bool = false, file:FileDescriptor?)
        {
            self.ignoreErrors = ignoreErrors
            self.file = file
        }
    }
}
extension SSGC.Logger:DiagnosticLogger
{
    public
    func emit(messages:consuming DiagnosticMessages) throws
    {
        if  self.ignoreErrors
        {
            messages.demoteErrors(to: .warning)
        }

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
