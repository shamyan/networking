//
//  ContentViewModel.swift
//  networking
//
//  Created by Harutyun Shamyan on 14.02.23.
//

import UIKit

final class ContentViewModel: ObservableObject {

    @Published private(set) var image = UIImage()
    private let imageDataProvider = DIContainer.shared.imageDataProvider

    func fetchImage() {
        let endpoint = APIEndpoints.getImageFromGoogle(path: "custom/blog-post-photo/gallery/mg-hs-624154219d3f5.jpg")
        imageDataProvider.request(with: endpoint) { result in
            guard case let .success(imageData) = result else { return }
            self.image = UIImage(data: imageData) ?? UIImage()
        }
    }

}

extension ContentViewModel {

    static let preview = ContentViewModel()

}
