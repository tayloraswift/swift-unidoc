extension HTTP
{
    protocol HeaderFormat:Sendable
    {
        init(origin:ServerOrigin, status:UInt)

        mutating
        func add(name:String, value:String)
    }
}
