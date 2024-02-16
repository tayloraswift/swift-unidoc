import Symbols

extension StaticLinker
{
    public
    typealias ResourceFile = _StaticLinkerResourceFile
}

/// The name of this protocol is ``StaticLinker.ResourceFile``.
public
protocol _StaticLinkerResourceFile:AnyObject, Identifiable
{
    /// Returns the content of the resource file.
    func read(as:[UInt8].Type) throws -> [UInt8]

    /// Returns the content of the text file as a string.
    func read(as:String.Type) throws -> String

    /// The path to the resource file, relative to the package root.
    var path:Symbol.File { get }

    /// The name of the resource file. This is a scalar string and should not include any path
    /// separators. It only needs to be unique within a single module.
    var name:String { get }
}
