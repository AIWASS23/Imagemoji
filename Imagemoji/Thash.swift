//
//  Thash.swift
//  Imagemoji
//
//  Created by Marcelo De Araújo on 07/10/22.
//

import Foundation

//var palette: some View {
//    ScrollingEmojisView(emojis: testEmojis)
//        .font(.system(size: defaultEmojiFontSize))
//}
//
//let testEmojis = "😆😇🥹😅🐔🐵🎯🐛👏🦀🐠🐮🦁🐯🐨🐳🦋🐷"
//}
//
//struct ScrollingEmojisView: View {
//
//let emojis: String
//var body: some View {
//
//    ScrollView(.horizontal) {
//        HStack {
//            ForEach(emojis.map { String($0) }, id: \.self) { emoji in
//                Text(emoji)
//                    .onDrag { NSItemProvider(object: emoji as NSString) }
//            }
//        }
//    }
//}
//}
//      UIDevice.current.userInterfaceIdiom != .pad {
//    .sink(
//        receiveCompletion: { result in
//            switch result {
//                case .finished:
//                    print("sucesso")
//                case .failure(let error):
//                    print("Error = \(error)")
//            }
//        },
//        receiveValue: { [weak self]image in
//            self?.backgroundImage = image
//            self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
//        }
//    )

//
//private var autosaveTimer: Timer?
//
//private func scheduleAutosave() {
//
//    autosaveTimer?.invalidate()
//    autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
//        self.autosave()
//    }
//}
//
//private struct Autosave {
//
//    static let filename = "Autosaved.emojiart"
//    static var url: URL? {
//
//        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        return documentDirectory?.appendingPathComponent(filename)
//    }
//    static let coalescingInterval = 5.0
//}
//
//private func autosave() {
//    if let url = Autosave.url {
//        save(to: url)
//    }
//}
//
//private func save(to url: URL) {
//
//    let thisfunction = "\(String(describing: self)).\(#function)"
//    do {
//        let data: Data = try emojiArt.json()
//        print("\(thisfunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
//        try data.write(to: url)
//        print("\(thisfunction) success!")
//    } catch let encodingError where encodingError is EncodingError {
//        print("\(thisfunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
//    } catch {
//        print("\(thisfunction) error = \(error)")
//    }
//
//}
