//
//  ContentView.swift
//  Imagemoji
//
//  Created by Marcelo De Araújo on 04/10/22.
//

import SwiftUI

struct ImagemojiDocumentView: View {

    @ObservedObject var document: ImagemojiDocument
    @ScaledMetric var defaultEmojiFontSize: CGFloat = 40
    @Environment(\.undoManager) var undoManager
    

    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooses(emojiFontSize: defaultEmojiFontSize)
        }
    }
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                    case .failed(let url):
                        showBackgroundImageFetchFailedAlert(url)
                    default:
                        break
                }
            }
            .onReceive(document.$backgroundImage) { image in
                if autozoom {
                    zoomToFit(image, in: geometry.size)
                }
            }
        }
    }
    @State private var autozoom = false
    @State private var alertToShow: IdentifiableAlert?

    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed: " + url.absoluteString, alert: {
            Alert(
                title: Text("Background Image Fetch"),
                message: Text("Couldn't load image from \(url)."),
                dismissButton: .default(Text("Ok"))
            )
        })
    }

    // MARK: - Drag and Drop
    
    private func drop(providers:[NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjetcs(ofType: URL.self) { url in
            autozoom = true
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjetcs(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjetcs(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: covertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiFontSize / zoomScale
                    )
                }
            }
        }
        return found
    }

    private func position(for emoji: ImagemojiModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.numX,emoji.numY), in: geometry)
    }

    private func covertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (numX: Int, numY: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }

    private func convertFromEmojiCoordinates(_ location: (numX: Int, numY: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.numX) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.numY) * zoomScale + panOffset.height
        )
    }

    private func fontSize(for emoji: ImagemojiModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }

    @SceneStorage("ImagemojiDocumentView.steadyStatePanOffset")
    private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero

    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }

    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latesDragGesturevalue, gesturePanOffset, _ in
                gesturePanOffset = latesDragGesturevalue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }

    }

    @SceneStorage("ImagemojiDocumentView.steadyStateZoomScale")
    private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1

    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latesGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latesGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }

    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }

    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ImagemojiDocumentView(document: ImagemojiDocument())
    }
}
