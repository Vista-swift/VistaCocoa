//
//  CocoaApplication.swift
//  Vista
//
//  Created by Patrick Horlebein on 06.12.15.
//  Copyright © 2015 Piay Softworks. All rights reserved.
//

import Foundation
import AppKit
import VistaCommon

// TODO(Patrick): Make a protocoll to define the methods a native application needs to have
public class CocoaApplication {

    let application: NSApplication

    let delegate: CocoaApplicationDelegate


    public init(withDelegate delegate: ApplicationDelegate) {
        application = NSApplication.sharedApplication()
        application.setActivationPolicy(.Regular)
        self.delegate = CocoaApplicationDelegate(withDelegate: delegate, application: application)
        application.delegate = self.delegate
    }

    public func run() {
        application.activateIgnoringOtherApps(true)
        application.run()
    }

    public func terminate() {
        NSApplication.sharedApplication().terminate(0)
    }

    public func pollEvents() -> CocoaEvents {
        return CocoaEvents()
    }
}

public class CocoaEvents: GeneratorType, SequenceType {

    public typealias Element = VIEvent

    public func generate() -> CocoaEvents {
        return self
    }

    public func next() -> Element? {
        let event = NSApp!.nextEventMatchingMask(Int(bitPattern: UInt(NSEventMask.AnyEventMask.rawValue)),
            untilDate: NSDate.distantPast(),
            inMode: NSDefaultRunLoopMode,
            dequeue: true)
        if let evt = event {
            //print("Event ", evt)
            NSApp!.sendEvent(evt)
            return 1
        }
        else {
            return nil
        }
    }
}

internal class CocoaApplicationDelegate: NSObject, NSApplicationDelegate {

    let inner: ApplicationDelegate
    weak var app: NSApplication?


    init(withDelegate delegate: ApplicationDelegate, application: NSApplication) {
        inner = delegate
        app = application
    }

    func applicationDidFinishLaunching(notification: NSNotification) {
        app!.stop(nil);
        inner.applicationDidFinishLaunching()
    }
}
