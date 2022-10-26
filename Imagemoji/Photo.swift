//
//  Photo.swift
//  Imagemoji
//
//  Created by Marcelo De Araújo on 26/10/22.
//

import Foundation
import SwiftUI
import PhotosUI

struct PhotoLibrary: UIViewControllerRepresentable {
    var handlePickedImage: (UIImage?) -> Void

    static var isAvailable: Bool {
        return true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var handlePickedImage: (UIImage?) -> Void

        init(handlePickedImage: @escaping (UIImage?) -> Void) {
            self.handlePickedImage = handlePickedImage
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let found = results.map { $0.itemProvider }.loadObjetcs(ofType: UIImage.self) { [weak self] image in
                self?.handlePickedImage(image)
            }
            if !found {
                handlePickedImage(nil)
            }
        }
    }
}
