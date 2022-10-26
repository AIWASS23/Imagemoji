//
//  PaletteManager.swift
//  Imagemoji
//
//  Created by Marcelo De Araújo on 07/10/22.
//

import SwiftUI

struct PaletteManager: View {

    @EnvironmentObject var store: PaletteStore
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                        .gesture(editMode == .active ? tap : nil)
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexset, newOffset in
                    store.palettes.move(fromOffsets: indexset, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
                    if presentationMode.wrappedValue.isPresented {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    var tap: some Gesture {
        TapGesture().onEnded {}
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .environmentObject(PaletteStore(named: "Preview"))
            .preferredColorScheme(.dark)
    }
}
