import SourceDiagnostics
import System_

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
            if  messages.status >= .fatal
            {
                self.failed = true
            }

        case .demoteErrors:
            messages.demoteErrors(to: .warning)
        }

        if  let output:FileDescriptor = self.output
        {
            let text:String = "\(messages)"
            try output.writeAll(text.utf8)
        }
        else
        {
            messages.emit(colors: .enabled)
        }

        if  self.failed
        {
            throw SSGC.ValidationError.init()
        }
    }
}
