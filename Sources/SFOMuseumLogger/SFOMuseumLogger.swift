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
        
        // DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        
        if options.max_logfiles > 0 {
            fileLogger.logFileManager.maximumNumberOfLogFiles = options.max_logfiles
        }
        
        fileLogger.logFormatter = ddLogFormatter(label: options.label) // description: options.label, hash: 0)
        
        DDLog.add(fileLogger)
                    
        let h = cocoaLumberjackHandler(label: options.label)
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
    metadataProvider: Logger.MetadataProvider? = nil,
    label: String
) -> LogHandler {
    
    return DDLogHandler.handlerFactory(for: log,
                                          defaultLogLevel: defaultLogLevel,
                                          loggingSynchronousAsOf: syncLoggingTreshold,
                                          synchronousLoggingMetadataKey: synchronousLoggingMetadataKey)(label)
}

// https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/CustomFormatters.md
// https://github.com/apple/swift-log/blob/main/Sources/Logging/Logging.swift#L1347

internal class ddLogFormatter: NSObject, DDLogFormatter {

    var label: String
    
    init(label: String) {
        self.label = label
    }
    
    func format(message logMessage: DDLogMessage) -> String? {
                
        var prettyMetadata: String = ""
        
        if let effectiveMetadata = logMessage.swiftLogInfo?.mergedMetadata {
            if let pretty = self.prettify(effectiveMetadata) {
                prettyMetadata = pretty
            }
        }
        
        let date_fmt = DateFormatter()
        date_fmt.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
        
        let date_str = date_fmt.string(from: logMessage.timestamp)
        
        return "\(date_str) \(logMessage.level.rawValue) \(self.label) : \(prettyMetadata) [source] \(logMessage.message)"
    }
    
    /* Cribbed from https://github.com/apple/swift-log/blob/main/Sources/Logging/Logging.swift#L1347 */
    
    internal static func prepareMetadata(base: Logger.Metadata, provider: Logger.MetadataProvider?, explicit: Logger.Metadata?) -> Logger.Metadata? {
           var metadata = base

           let provided = provider?.get() ?? [:]

           guard !provided.isEmpty || !((explicit ?? [:]).isEmpty) else {
               // all per-log-statement values are empty
               return nil
           }

           if !provided.isEmpty {
               metadata.merge(provided, uniquingKeysWith: { _, provided in provided })
           }

           if let explicit = explicit, !explicit.isEmpty {
               metadata.merge(explicit, uniquingKeysWith: { _, explicit in explicit })
           }

           return metadata
       }

       private func prettify(_ metadata: Logger.Metadata) -> String? {
           if metadata.isEmpty {
               return nil
           } else {
               return metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: " ")
           }
       }
}

