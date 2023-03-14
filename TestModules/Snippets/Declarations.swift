public
enum Declarations<T>
{
}
extension Declarations
{
    @discardableResult
    public
    func defaultArguments<U>(a:Int = 5, b:String = "bbb", c:T, d:(inout Void) -> () = { _ in }) -> U
    {
        fatalError()
    }
}
