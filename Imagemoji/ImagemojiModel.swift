//
//  ImagemojiModel.swift
//  Imagemoji
//
//  Created by Marcelo De Araújo on 04/10/22.
//

import Foundation

struct ImagemojiModel: Codable {

    var background = Background.blank
    var emojis = [Emoji]()
    private var uniqueEmojiId = 0

    struct Emoji: Identifiable, Hashable, Codable {

        let text: String
        var numX: Int
        var numY: Int
        var size: Int
        let id: Int

        fileprivate init(text: String, numX: Int, numY: Int, size: Int, id: Int) {

            self.text = text
            self.numX = numX
            self.numY = numY
            self.size = size
            self.id = id
        }
    }

    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    init(json: Data) throws {
        self = try JSONDecoder().decode(ImagemojiModel.self, from: json)
    }

    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try ImagemojiModel(json: data)
    }

    init() {}

    mutating func addEmoji(_ text: String, at location: (numX: Int, numY: Int), size: Int) {

        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, numX: location.numX, numY: location.numY, size: size, id: uniqueEmojiId))
    }
}
