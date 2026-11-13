/*
Copyright (c) 2026 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation

/// The result of a transaction. Either ``completed`` or ``notCompleted``.
///
/// Non-completed transactions are logged too. The reason for non-completion, if known, is carried
/// on the entry's `reasonOfNoncompletion` field.
public enum TransactionResult: String, Codable, Equatable, Sendable {
    /// The transaction completed successfully.
    case completed = "Completed"
    /// The transaction did not complete.
    case notCompleted = "NotCompleted"
}
