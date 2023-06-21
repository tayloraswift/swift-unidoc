import Symbols

#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

extension Symbolicator
{
    struct Demangler
    {
        private
        typealias Function = @convention(c)
        (
            _ name:UnsafePointer<UInt8>?,
            _ count:Int,
            _ output:UnsafeMutablePointer<UInt8>?,
            _ capacity:UnsafeMutablePointer<Int>?,
            _ flags:UInt32
        ) -> UnsafeMutablePointer<Int8>?

        private
        let function:Function

        private
        init(_ function:Function)
        {
            self.function = function
        }
    }
}
extension Symbolicator.Demangler
{
    func demangle(_ symbol:ScalarSymbol) -> String?
    {
        // '$s'
        let prefixed:String = "$\(symbol.rawValue)" // not the description!
        if  let string:UnsafeMutablePointer<Int8> =
                self.function(prefixed, prefixed.utf8.count, nil, nil, 0)
        {
            defer
            {
                string.deallocate()
            }
            return String.init(cString: string)
        }
        else
        {
            return nil
        }
    }
}
extension Symbolicator.Demangler
{
    init?()
    {
        #if canImport(Glibc) || canImport(Darwin)
        guard let swift:UnsafeMutableRawPointer = dlopen(nil, RTLD_NOW)
        else
        {
            return nil
        }
        guard let symbol:UnsafeMutableRawPointer = dlsym(swift, "swift_demangle")
        else
        {
            return nil
        }
        self.init(unsafeBitCast(symbol, to: Function.self))
        #else
        return nil
        #endif
    }
}
