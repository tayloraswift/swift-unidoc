extension SymbolAvailability
{
    @frozen public 
    enum Platform:String, CaseIterable, Hashable, Sendable 
    {
        case iOS 
        case macOS
        case macCatalyst
        case tvOS
        case watchOS
        case windows    = "Windows"
        case openBSD    = "OpenBSD"
        
        case iOSApplicationExtension
        case macOSApplicationExtension
        case macCatalystApplicationExtension
        case tvOSApplicationExtension
        case watchOSApplicationExtension
    }
}
