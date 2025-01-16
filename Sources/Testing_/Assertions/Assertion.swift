public
struct Assertion
{
    public
    let function:String
    public
    let path:[String]
    public
    let file:String
    public
    let line:Int

    @inlinable public
    init(function:String, path:[String], file:String, line:Int)
    {
        self.function = function
        self.path = path
        self.file = file
        self.line = line
    }
}

