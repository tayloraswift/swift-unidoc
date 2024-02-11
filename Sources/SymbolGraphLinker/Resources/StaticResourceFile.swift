import Symbols

public
protocol StaticResourceFile:AnyObject, Identifiable
{
    associatedtype Content

    /// Returns the content of the resource file.
    func read() throws -> Content

    /// The path to the resource file, relative to the package root.
    var path:Symbol.File { get }

    /// The name of the resource file. This is a scalar string and should not include any path
    /// separators. It only needs to be unique within a single module.
    var name:String { get }
}
