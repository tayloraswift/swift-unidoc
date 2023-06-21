extension StaticDiagnostic.Context
{
    /// A human-readable representation of a ``SourceLocation``.
    struct Header
    {
        let file:File
        let line:Int
        let column:Int

        init(file:File, line:Int, column:Int)
        {
            self.file = file
            self.line = line
            self.column = column
        }
    }
}
extension StaticDiagnostic.Context<Int32>.Header
{
    func symbolicated(with symbolicator:Symbolicator) -> StaticDiagnostic.Context<String>.Header
    {
        .init(file: symbolicator[file: self.file], line: self.line, column: self.column)
    }
}
extension StaticDiagnostic.Context.Header:CustomStringConvertible
    where File:CustomStringConvertible
{
    var description:String
    {
        //  Uses 1-indexing for consistency with VSCode
        "\(self.file):\(self.line + 1):\(self.column + 1)"
    }
}
