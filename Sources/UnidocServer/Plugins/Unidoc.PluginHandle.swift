import Atomics

extension Unidoc
{
    struct PluginHandle:Sendable
    {
        let plugin:any Plugin
        let active:ManagedAtomic<Bool>

        init(plugin:any Plugin)
        {
            self.plugin = plugin
            self.active = .init(plugin.enabledInitially)
        }
    }
}
