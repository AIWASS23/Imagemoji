//
//  PaletteStore.swift
//  Imagemoji
//
//  Created by Marcelo De AraΓΊjo on 06/10/22.
//

import SwiftUI

struct Palette: Identifiable, Codable, Hashable {

    var name: String
    var emojis: String
    var id: Int

    fileprivate init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}

class PaletteStore: ObservableObject {

    let name: String

    @Published var palettes = [Palette]() {
        didSet {
            storeInuserdefaults()
        }
    }

    private var userDefaultsKey: String {
        "PaletteStore:" + name
    }

    private func storeInuserdefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
//        UserDefaults.standard.set(palettes.map { [$0.name, $0.emojis, String($0.id)] }, forKey: userDefaultsKey)
    }

    private func restoreFromuserDefaults() {

        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
        let decodedPalettes = try? JSONDecoder().decode(Array<Palette>.self,
        from: jsonData) {
            palettes = decodedPalettes
        }
//        if let palettesAsPropertylist = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String]] {
//            for paletteAsArray in palettesAsPropertylist {
//                if paletteAsArray.count == 3, let id = Int(paletteAsArray[2]), !palettes.contains(where: { $0.id == id }) {
//                    let palette = Palette(name: paletteAsArray[0], emojis: paletteAsArray[1], id: id)
//                    palettes.append(palette)
//                }
//            }
//        }
    }

    init(named name: String) {

        self.name = name
        restoreFromuserDefaults()
        if palettes.isEmpty {

            print("using built-in palettes")
            insertPalette(named: "VeΓ­culos", emojis: "π’β΄π³π₯πππππππ΄ππΈ")
            insertPalette(named: "Esportes", emojis: "β½οΈπππ₯βΎοΈπΈππ₯π±π₯πΉπΉπΉ")
            insertPalette(named: "Musica", emojis: "π₯π»πͺπΈπͺπΊπ·πͺπ€πΉπ§πΌπ¬")
            insertPalette(named: "Animais", emojis: "πΆπ±π­πΉπ°π¦π»πΌπ»ββοΈπ¨π―π¦π?π·")
            insertPalette(named: "Animais Faces", emojis: "π΅ππππ¦πΊπΈπΉπ»πΌπ½ππΏπΎ")
            insertPalette(named: "Plantas", emojis: "π·πΉπ₯ππ²π³π΄ππππͺ΄ππͺΈππ±")
            insertPalette(named: "Tempo", emojis: "ππππβοΈπ€π¨π©βπ§π¦βοΈπ₯βοΈβοΈβοΈππ¨π«")
            insertPalette(named: "Covid", emojis: "π€§π·π€π€’π€?ππ¨π§ͺ")
        } else {
            print("Sucesso: \(palettes)")
        }
    }

    // MARK: - Intent

    func palette(at index: Int) -> Palette{
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }

    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }

    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}
