//
//  ImagemojiDocument.swift
//  Imagemoji
//
//  Created by Marcelo De Araújo on 04/10/22.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let imagemoji = UTType(exportedAs: "Marcelo-de-Arau-jo.Imagemoji")
}

class ImagemojiDocument: ReferenceFileDocument {

    static var readableContentTypes = [UTType.imagemoji]
    static var writeableContentTypes = [UTType.imagemoji]

    typealias Snapshot = Data

    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try ImagemojiModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }

    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }

    @Published private(set) var emojiArt: ImagemojiModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        } // 58:21
    }

        init() {
            emojiArt = ImagemojiModel()
        }
    var emojis: [ImagemojiModel.Emoji] { emojiArt.emojis }
    var background: ImagemojiModel.Background { emojiArt.background }

    // MARK: -Background
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle

    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }

    private var backgroundImageFecthCancellable: AnyCancellable?

    private func fetchBackgroundImageDataIfNecessary() {

        backgroundImage = nil

        switch emojiArt.background {

            case .url(let url):
                backgroundImageFetchStatus = .fetching
                backgroundImageFecthCancellable?.cancel()
                let session = URLSession.shared
                let publisher = session.dataTaskPublisher(for: url)
                    .map{ (data, urlResponse) in UIImage(data: data) }
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)

                backgroundImageFecthCancellable = publisher
                    .sink { [weak self]image in
                        self?.backgroundImage = image
                        self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                    }





//                .assign(to: \ImagemojiDocument.backgroundImage, on: self)
//            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.emojiArt.background == ImagemojiModel.Background.url(url) {
//                        self?.backgroundImageFetchStatus = .idle
//                        if imageData != nil {
//                            self?.backgroundImage = UIImage(data: imageData!)
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.backgroundImageFetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
            case .imageData(let data):
                backgroundImage = UIImage(data: data)
            case .blank:
                break
        }
    }

    // MARK: -Intent(s)

    func setBackground(_ background: ImagemojiModel.Background) {
        emojiArt.background = background
        print("background set to \(background)")
    }
    func addEmoji(_ emoji: String, at location:(numX: Int, numY: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    func moveEmoji(_ emoji: ImagemojiModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].numX += Int(offset.width)
            emojiArt.emojis[index].numY += Int(offset.height)
        }
    }
    func scaleEmoji(_ emoji: ImagemojiModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(operation)
    }
}
