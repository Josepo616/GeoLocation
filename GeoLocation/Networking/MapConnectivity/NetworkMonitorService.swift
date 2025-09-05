//
//  NetworkMonitorService.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/3/25.
//

import Foundation
import Network
import Combine

/// A service class that monitors network connectivity, provides a publisher to
/// track connectivity changes, and performs periodic checks to verify internet access.
final class NetworkMonitorService {
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitorQueue")
    private let connectivitySubject = CurrentValueSubject<Bool, Never>(true)
    private var cancellables = Set<AnyCancellable>()
    private let checkURL = URL(string: "https://www.apple.com")

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        connectivitySubject.eraseToAnyPublisher()
    }

    /// Initializes the monitor and starts periodic connectivity checks.
    /// The monitor updates whenever the network path changes.
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.startScheduledConnectivityChecks()
        }

        monitor.start(queue: monitorQueue)
        startScheduledConnectivityChecks()
    }

    /// Starts a scheduled connectivity check every 5 seconds, updating the connectivity status.
    /// Stops previous checks when called to avoid multiple timers.
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

    /// Checks if the device has internet connectivity by sending a "HEAD" request to a check URL.
    /// If the response is successful, returns true. Otherwise, returns false.
    func checkInternetConnectivity() -> AnyPublisher<Bool, Never> {
        guard let checkURL = checkURL else {
            return Just(false).eraseToAnyPublisher()
        }

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
