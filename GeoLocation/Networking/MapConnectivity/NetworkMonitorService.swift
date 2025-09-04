//
//  NetworkMonitorService.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/3/25.
//

import Foundation
import Network
import Combine

final class NetworkMonitorService {
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitorQueue")
    private let connectivitySubject = CurrentValueSubject<Bool, Never>(true)
    private var cancellables = Set<AnyCancellable>()
    private let checkURL = URL(string: "https://www.apple.com")!

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        connectivitySubject.eraseToAnyPublisher()
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.startScheduledConnectivityChecks()
        }

        monitor.start(queue: monitorQueue)
        startScheduledConnectivityChecks()
    }

    private func startScheduledConnectivityChecks() {
        cancellables.removeAll()

        Timer
            .publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self = self else {
                    return Just(false).eraseToAnyPublisher()
                }
                return self.checkInternetConnectivity()
            }
            .sink { [weak self] isConnected in
                self?.connectivitySubject.send(isConnected)
            }
            .store(in: &cancellables)
    }

    func checkInternetConnectivity() -> AnyPublisher<Bool, Never> {
        var request = URLRequest(url: checkURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 2

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    return false
                }

                let success = httpResponse.statusCode == 200
                return success
            }
            .replaceError(with: {
                return false
            }())
            .eraseToAnyPublisher()
    }
}
