import Foundation

/// A utility actor that ensures a block of code is executed only once and can return a value
public actor ExecutingOnce {
  private var hasExecuted = false
  private let block: @Sendable () async -> Void

  /// Initialize with an async block of code to execute once
  /// - Parameter block: The async code to execute only once
  public init(_ block: @escaping @Sendable () async -> Void) {
    self.block = block
  }

  /// Execute the block if it hasn't been executed yet
  public func executeIfNecessary() async {
    guard !hasExecuted else { return }
    hasExecuted = true
    await block()
  }

  /// Check if the block has already been executed
  public var hasBeenExecuted: Bool {
    hasExecuted
  }
}
