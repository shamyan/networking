//
//  NetworkLayer.swift
//  networking
//
//  Created by Harutyun Shamyan on 14.02.23.
//

import Foundation

// MARK: - API Configuration

struct AppConfiguration {
    var imageBaseURL: String = "https://d1hv7ee95zft1i.cloudfront.net"
}

class DIContainer {

    static let shared = DIContainer()

    lazy var appConfiguration = AppConfiguration()

    lazy var imageDataProvider: DataProvider = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.imageBaseURL)!)
        let imageDataNetwork = DefaultNetworkClient(config: config)
        return DefaultDataProvider(with: imageDataNetwork)
    }()

}

// MARK: - Endpoints definitions

struct APIEndpoints {

    static func getImageFromGoogle(path: String) -> Endpoint<Data> {
        Endpoint(
            path: path,
            method: .get,
            responseDecoder: RawDataResponseDecoder()
        )
    }

}
