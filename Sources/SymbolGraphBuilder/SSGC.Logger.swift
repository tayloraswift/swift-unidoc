import SourceDiagnostics
import System

extension SSGC
{
    public final
    class Logger
    {
        private
        let validation:ValidationBehavior
        private
        let output:FileDescriptor?

        private(set)
        var failed:Bool

        public
        init(validation:ValidationBehavior, file output:FileDescriptor?)
        {
            self.validation = validation
            self.output = output
            self.failed = false
        }
    }
}
extension SSGC.Logger
{
    static func `default`() -> Self
    {
        .init(validation: .ignoreErrors, file: nil)
    }
}
extension SSGC.Logger:DiagnosticLogger
{
    public
    func emit(messages:consuming DiagnosticMessages) throws
    {
        switch self.validation
        {
        case .warningsAsErrors:
            if  messages.status >= .warning
            {
                self.failed = true
            }

        case .failOnErrors:
            if  messages.status >= .error
            {
                self.failed = true
            }

        case .ignoreErrors:
            break

        case .demoteErrors:
            messages.demoteErrors(to: .warning)
        }

        guard
        let output:FileDescriptor = self.output
        else
        {
            messages.emit(colors: .enabled)
            return
        }

        let text:String = "\(messages)"
        try output.writeAll(text.utf8)

        if  self.failed
        {
            throw SSGC.ValidationError.init()
        }
    }
}
