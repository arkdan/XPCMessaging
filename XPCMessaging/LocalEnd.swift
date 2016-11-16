//
//  LocalEnd.swift
//  InterProcess
//
//  Created by ark dan on 11/11/16.
//  Copyright © 2016 arkdan. All rights reserved.
//

import Foundation
import OpenEmuXPCCommunicator

public class LocalEnd<LocalProtocol>: NSObject, NSXPCListenerDelegate {

    public var debug = ""

    fileprivate var listener: NSXPCListener?

    fileprivate let ppp: Protocol
    public let workerObject: LocalProtocol

    public let localIdentifier: String

    public init(localIdentifier: String, localProtocol: Protocol, workerObject: LocalProtocol) {
        self.localIdentifier = localIdentifier
        self.ppp = localProtocol
        self.workerObject = workerObject
        super.init()
    }

    public func register() {
        listener = NSXPCListener.anonymous()
        listener?.delegate = self
        listener?.resume()
        let endPoint = listener!.endpoint
        OEXPCCAgent.default().register(endPoint, forIdentifier: localIdentifier) { (success) in
            print("\(self.debug)-agent-register \(success)")
        }
    }

    public func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        print("\(debug)-listener")

        newConnection.exportedInterface = NSXPCInterface(with: ppp)
        newConnection.exportedObject = workerObject
        newConnection.resume()
        self.listener = nil

        return true
    }
}


