extension HTTP
{
    protocol HeaderFormat:Sendable
    {
        init(origin:Origin, status:UInt)

        mutating
        func add(name:String, value:String)
    }
}
