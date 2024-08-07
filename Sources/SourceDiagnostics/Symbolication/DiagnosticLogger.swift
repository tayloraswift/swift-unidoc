public 
protocol DiagnosticLogger
{
    func emit(messages:consuming DiagnosticMessages) throws
}
