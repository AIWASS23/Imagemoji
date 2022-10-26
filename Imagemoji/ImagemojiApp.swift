//
//  ImagemojiApp.swift
//  Imagemoji
//
//  Created by Marcelo De Araújo on 04/10/22.
//

import SwiftUI

@main
struct ImagemojiApp: App {

    @StateObject var document = ImagemojiDocument()
    @StateObject var paletteStore = PaletteStore(named: "Default")
    
    var body: some Scene {
        DocumentGroup(newDocument: { ImagemojiDocument() }) { config in
            ImagemojiDocumentView(document: config.document)
                .environmentObject(paletteStore)
        }
    }
}
