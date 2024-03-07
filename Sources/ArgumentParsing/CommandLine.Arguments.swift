extension CommandLine
{
    public
    struct Arguments
    {
        private
        var list:ArraySlice<String>

        public
        init()
        {
            let arguments:[String] = UnsafeBufferPointer<UnsafeMutablePointer<CChar>?>.init(
                start: CommandLine.unsafeArgv,
                count: Int.init(CommandLine.argc)).compactMap
            {
                guard
                let string:UnsafeMutablePointer<CChar> = $0,
                let string:String = .init(validatingUTF8: string)
                else
                {
                    return nil
                }

                return string
            }

            self.list = arguments[1...]
        }
    }
}
extension CommandLine.Arguments
{
    public mutating
    func next() -> String?
    {
        self.list.popFirst()
    }

    public mutating
    func next(for option:String) throws -> String
    {
        guard
        let value:String = self.next()
        else
        {
            throw CommandLine.ArgumentError.missing(option)
        }

        return value
    }

    public mutating
    func next<Value>(for option:String, as _:Value.Type = Value.self) throws -> Value
        where Value:LosslessStringConvertible
    {
        let value:String = try self.next(for: option)

        guard
        let value:Value = .init(value)
        else
        {
            throw CommandLine.ArgumentError.invalid(option, value: value)
        }

        return value
    }
}
