import Symbols

extension [Symbol.Decl: Symbol.Module] {
    func select(culture: Symbol.Module) -> [Symbol.Decl] {
        self.reduce(into: []) {
            if  $1.value == culture {
                $0.append($1.key)
            }
        }
    }
}
