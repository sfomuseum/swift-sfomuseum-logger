import Foundation
import Logging
import CocoaLumberjack
import CocoaLumberjackSwiftLogBackend

public struct SFOMuseumLoggerOptions {
    public var label: String
    public var console: Bool = true
    public var logfile: String?
    public var verbose: Bool = false
    public var handlers: [LogHandler]?
    
    public init(label: String, console: Bool = true, logfile: String? = nil, verbose: Bool = false, handlers: [LogHandler]? = nil) {
        self.label = label
        self.console = console
        self.logfile = logfile
        self.verbose = verbose
        self.handlers = handlers
    }
}

public func NewSFOMuseumLogger(_ options: SFOMuseumLoggerOptions) throws -> Logger  {
    
    if options.console {
        DDLog.add(DDOSLogger.sharedInstance)
    }
    
    if options.logfile != nil {
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.value(forKeyPath: options.logfile!)
        
        // fileLogger.maximumFileSize = 100
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    LoggingSystem.bootstrapWithCocoaLumberjack()
    return Logger(label: options.label)
}

public func xNewSFOMuseumLogger(_ options: SFOMuseumLoggerOptions) throws -> Logger  {

    var handlers = options.handlers
    
    if handlers == nil {
        handlers = DefaultSFOMuseumLogHandlers(options)
    }
    
    LoggingSystem.bootstrap {_ in
        return MultiplexLogHandler(handlers!)
    }

    return Logger(label: options.label)
}

public func DefaultSFOMuseumLogHandlers(_ options: SFOMuseumLoggerOptions) -> [LogHandler] {
  
    var handlers = [LogHandler]()
    
    if options.console {
        let h = StreamLogHandler.standardOutput(label: options.label)
        handlers.append(h)
    }
    
    for (idx, _) in handlers.enumerated() {
        
        if options.verbose {
            handlers[idx].logLevel = .trace
        } else {
            handlers[idx].logLevel = .info
        }
    }
    
    return handlers
}
