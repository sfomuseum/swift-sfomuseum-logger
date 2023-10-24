import Foundation
import Logging
import CocoaLumberjack
import CocoaLumberjackSwiftLogBackend

public struct SFOMuseumLoggerOptions {
    public var label: String
    public var console: Bool = true
    public var logfile: Bool = false
    public var max_logfiles: UInt = 7
    public var verbose: Bool = false
    public var handlers: [LogHandler]?
    
    public init(label: String, console: Bool = true, logfile: Bool = false, max_logfiles: UInt = 7, verbose: Bool = false, handlers: [LogHandler]? = nil) {
        self.label = label
        self.console = console
        self.logfile = logfile
        self.max_logfiles = max_logfiles
        self.verbose = verbose
        self.handlers = handlers
    }
}

public func NewSFOMuseumLogger(_ options: SFOMuseumLoggerOptions) throws -> Logger  {

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
    
    if options.logfile {
        
        DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger

        fileLogger.rollingFrequency = 60 * 60 * 24
        
        if options.max_logfiles > 0 {
            fileLogger.logFileManager.maximumNumberOfLogFiles = options.max_logfiles
        }
        
        DDLog.add(fileLogger)
            
        let h = cocoaLumberjackHandler()
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

// Cribbed from CocoaLumberjack source

internal func cocoaLumberjackHandler(
    for log: DDLog = .sharedInstance,
    defaultLogLevel: Logger.Level = .info,
    loggingSynchronousAsOf syncLoggingTreshold: Logger.Level = .error,
    synchronousLoggingMetadataKey: Logger.Metadata.Key = DDLogHandler.defaultSynchronousLoggingMetadataKey,
    metadataProvider: Logger.MetadataProvider? = nil
) -> LogHandler {
    
    return DDLogHandler.handlerFactory(for: log,
                                          defaultLogLevel: defaultLogLevel,
                                          loggingSynchronousAsOf: syncLoggingTreshold,
                                          synchronousLoggingMetadataKey: synchronousLoggingMetadataKey)("log")
}
