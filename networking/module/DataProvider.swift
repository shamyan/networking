//
//  DataProvider.swift
//  networking
//
//  Created by Harutyun Shamyan on 14.02.23.
//

import Foundation

public enum DataProviderError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

public protocol DataProvider {

    typealias CompletionHandler<T> = (Result<T, DataProviderError>) -> Void

    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T

    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void

}

public protocol DataProviderErrorResolver {
    func resolve(error: NetworkError) -> Error
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public protocol DataProviderErrorLogger {
    func log(error: Error)
}

public final class DefaultDataProvider {

    private let networkClient: NetworkClient
    private let errorResolver: DataProviderErrorResolver
    private let errorLogger: DataProviderErrorLogger

    public init(
        with networkClient: NetworkClient,
        errorResolver: DataProviderErrorResolver = DefaultDataProviderErrorResolver(),
        errorLogger: DataProviderErrorLogger = DefaultDataProviderErrorLogger()
    ) {
        self.networkClient = networkClient
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }

}

extension DefaultDataProvider: DataProvider {

    public func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T {
        networkClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, DataProviderError> = self.decode(data: data, decoder: endpoint.responseDecoder)
                DispatchQueue.main.async { return completion(result) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }
    }

    public func request<E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E : ResponseRequestable, E.Response == Void {
        networkClient.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                DispatchQueue.main.async { return completion(.success(())) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }
    }

    // MARK: - Private

    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, DataProviderError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }

    private func resolve(networkError error: NetworkError) -> DataProviderError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }

}

// MARK: - Logger

public final class DefaultDataProviderErrorLogger: DataProviderErrorLogger {

    public init() { }

    public func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }

}

// MARK: - Error Resolver

public class DefaultDataProviderErrorResolver: DataProviderErrorResolver {

    public init() { }

    public func resolve(error: NetworkError) -> Error {
        return error
    }

}

// MARK: - Response Decoders

public class JSONResponseDecoder: ResponseDecoder {

    private let jsonDecoder = JSONDecoder()

    public init() { }

    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }

}

public class RawDataResponseDecoder: ResponseDecoder {

    public init() { }

    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }

    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }

}
