public
protocol SystemCommand
{
    static
    var name:String { get }

    func augment(_ arguments:[String]) -> [String]
}
extension SystemCommand
{
    @inlinable public
    func run(_ arguments:String...) throws -> SystemProcess
    {
        try self.run(arguments)
    }
    @inlinable public
    func run(_ arguments:[String]) throws -> SystemProcess
    {
        try .init(command: Self.name, arguments: self.augment(arguments))
    }
}
