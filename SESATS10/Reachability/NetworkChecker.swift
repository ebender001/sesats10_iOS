//
//  NetworkChecker.swift
//  SESATS10
//
//  Created by Edward Bender on 12/31/25.
//

import Foundation
import Network
import Combine


class NetworkChecker: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    @Published private(set) var connected = false
    
    init() {
        checkConnection()
    }
    
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.connected = true
                } else {
                    self.connected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}
