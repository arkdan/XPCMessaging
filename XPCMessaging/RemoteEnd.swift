//
//  RemoteEnd.swift
//  InterProcess
//
//  Created by ark danon 11/14/16.
//  Copyright © 2016 arkdan. All rights reserved.
//

import Foundation
import OpenEmuXPCCommunicator



public class RemoteEnd<RemoteProtocol>: NSObject {
    public let remoteIdentifier: String

    public var debug = ""

    fileprivate var remoteProxy: RemoteProtocol?

    fileprivate let ppp: Protocol

    public init(remoteIdentifier: String, remoteProtocol: Protocol) {
        self.ppp = remoteProtocol
        self.remoteIdentifier = remoteIdentifier
    }

    public func connect(done: @escaping (RemoteProtocol) -> ()) {
        print("\(RemoteProtocol.self)")
        OEXPCCAgent.default().retrieveListenerEndpoint(forIdentifier: remoteIdentifier) { (endpoint) in
            guard let endpoint = endpoint else {
                print("\(self.debug)-retrieveListenerEndpoint: nil endpoint")
                return
            }

            let connection = NSXPCConnection(listenerEndpoint: endpoint)
            connection.remoteObjectInterface = NSXPCInterface(with: self.ppp)
            connection.resume()
            guard let remote = connection.remoteObjectProxy as? RemoteProtocol else {
                print("remoteObjectProxy does not conform to \(RemoteProtocol.self)")
                fatalError()
            }
            self.remoteProxy = remote
            print("\(self.debug)-resumeConnection-endpoint-retrieved")
            done(remote)
        }
    }

}
