import SwiftUI

struct Category: Identifiable {
    let id: String
    let label: String
    let symbol: String   // SF Symbol name
    let color: Color
}

let allCategories: [Category] = [
    Category(id: "moradia",      label: "Moradia",        symbol: "house.fill",          color: Color(hex: "f472b6")), // rose-400
    Category(id: "casa",         label: "Contas de casa", symbol: "bolt.fill",           color: Color(hex: "facc15")), // amber
    Category(id: "cartao",       label: "Cartão",         symbol: "creditcard.fill",     color: Color(hex: "60a5fa")), // blue-400
    Category(id: "assinaturas",  label: "Assinaturas",    symbol: "play.rectangle.fill", color: Color(hex: "a78bfa")), // violet-400
    Category(id: "transporte",   label: "Transporte",     symbol: "car.fill",            color: Color(hex: "34d399")), // emerald
    Category(id: "saude",        label: "Saúde",          symbol: "heart.fill",          color: Color(hex: "fb7185")), // rose-500
    Category(id: "educacao",     label: "Educação",       symbol: "book.fill",           color: Color(hex: "c4b5fd")), // violet-300
    Category(id: "lazer",        label: "Lazer",          symbol: "sparkles",            color: Color(hex: "7dd3fc")), // sky-300
]

func catById(_ id: String) -> Category {
    allCategories.first { $0.id == id } ?? allCategories[0]
}
