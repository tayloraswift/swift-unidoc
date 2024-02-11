public
protocol StaticTextFile<ID>:StaticResourceFile where Content == String
{
    /// Returns the content of the text file as raw UTF-8 data.
    func utf8() throws -> [UInt8]
}
