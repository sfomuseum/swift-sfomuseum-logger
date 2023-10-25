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
                
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        
        if options.max_logfiles > 0 {
            fileLogger.logFileManager.maximumNumberOfLogFiles = options.max_logfiles
        }
        
        fileLogger.logFormatter = ddLogFormatter(label: options.label)
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

/* Cribbed from CocoaLumberjack source */

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
         
        var str_metadata = ""
        var str_label = ""
        var str_source = ""
        var str_level = ""
        
        if let log_info = logMessage.swiftLogInfo {
            
            let swift_logger = log_info.logger
            let swift_message = log_info.message
            let swift_metadata = log_info.mergedMetadata
            
            str_level = swift_message.level.rawValue
            str_source = swift_message.source
            str_label = swift_logger.label
            
            if let pretty = self.prettify(swift_metadata) {
                str_metadata = pretty
            }
            
        } else {
            
            str_source = logMessage.fileName
            str_label = self.label
            
            switch logMessage.level {
            case .all:
                str_level = "all"
            case .verbose:
                str_level = "verbose"
            case .debug:
                str_level = "debug"
            case .info:
                str_level = "info"
            case .warning:
                str_level = "warning"
            case .error:
                str_level = "error"
            default:
                str_level = "unknown (\(logMessage.level))"
            }
        }
        
        let date_fmt = DateFormatter()
        date_fmt.dateFormat = "yyyy/MM/dd HH:mm:ssZ"
        
        let str_date = date_fmt.string(from: logMessage.timestamp)
        
        return "\(str_date) \(str_level) \(str_label) : \(str_metadata) [\(str_source)] \(logMessage.message)"
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

