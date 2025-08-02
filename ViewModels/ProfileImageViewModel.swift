//
//  ProfileImageViewModel.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import SwiftUI
import PhotosUI

class ProfileImageViewModel: ObservableObject {
    @Published var selectedImage: UIImage? = nil
    @Published var imageData: Data? = nil

    func setImage(from item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    self.imageData = data
                    self.selectedImage = UIImage(data: data)
                    saveImageToUserDefaults(data)
                }
            }
        }
    }

    func loadImageFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "profileImage") {
            self.imageData = savedData
            self.selectedImage = UIImage(data: savedData)
        }
    }

    private func saveImageToUserDefaults(_ data: Data) {
        UserDefaults.standard.set(data, forKey: "profileImage")
    }
}

