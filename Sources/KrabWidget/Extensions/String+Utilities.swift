import Foundation

// MARK: - String Extensions for KrabWidget
// Utility extensions used throughout the widget for text processing.

public extension String {
    
    /// Truncates the string to a maximum length, appending an ellipsis if needed.
    ///
    /// - Parameter maxLength: The maximum number of characters to keep.
    /// - Returns: The original string if shorter than `maxLength`,
    ///   otherwise a truncated string ending with `"…"`.
    ///
    /// - Example:
    ///   ```swift
    ///   "Hello, World!".truncated(to: 7) // "Hello, …"
    ///   "Hi".truncated(to: 10)           // "Hi"
    ///   ```
    func truncated(to maxLength: Int) -> String {
        guard count > maxLength else { return self }
        return String(prefix(maxLength)) + "…"
    }
    
    /// Returns `nil` if the string is empty or contains only whitespace.
    ///
    /// Useful for cleaning up optional user input.
    ///
    /// - Example:
    ///   ```swift
    ///   "  ".nilIfBlank   // nil
    ///   "hello".nilIfBlank // "hello"
    ///   ```
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : self
    }
    
    /// A Boolean value indicating whether the string looks like a valid URL.
    var looksLikeURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
}
