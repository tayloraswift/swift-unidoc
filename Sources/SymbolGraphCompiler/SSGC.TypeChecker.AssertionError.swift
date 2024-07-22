extension SSGC.TypeChecker
{
    struct AssertionError:Error
    {
        let message:String

        init(message:String)
        {
            self.message = message
        }
    }
}
