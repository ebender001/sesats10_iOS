//
//  NetworkChecker.swift
//  SESATS10
//
//  Created by Edward Bender on 12/31/25.
//

import Foundation
import Network
import Combine


final class NetworkManager: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    @Published private(set) var connected = false
    
    init() {
        monitor.pathUpdateHandler = {[weak self] path in
            DispatchQueue.main.async {
                self?.connected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
