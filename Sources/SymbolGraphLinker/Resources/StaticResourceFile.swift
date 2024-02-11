import Symbols

public
protocol StaticResourceFile<ID>:AnyObject, Identifiable
{
    associatedtype Content

    /// Returns the content of the resource file.
    func read() throws -> Content

    /// The path to the resource file, relative to the package root.
    var path:Symbol.File { get }

    /// The name of the resource file. This is a scalar string. It should not include any file
    /// extensions or path separators. It only needs to be unique within a single file type
    /// within a single module.
    var name:String { get }

    /// An identifier for the resource file that is unique across an entire package.
    override
    var id:ID { get }
}
