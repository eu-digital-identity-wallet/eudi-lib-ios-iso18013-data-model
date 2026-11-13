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
import os
@preconcurrency import LocalAuthentication

public final class ThreadSafeAuthContext: @unchecked Sendable {
    private let lock: OSAllocatedUnfairLock<LAContext>

    public init(context: LAContext = LAContext()) {
        lock = OSAllocatedUnfairLock(initialState: context)
    }

    public func invalidate() {
        lock.withLock { context in
            context.invalidate()
        }
    }

    public func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        lock.withLockUnchecked { context in
            context.canEvaluatePolicy(policy, error: error)
        }
    }

    public func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        let context = lock.withLock { $0 }
        return try await context.evaluatePolicy(policy, localizedReason: localizedReason)
    }

    public func withLAContext<T>(_ body: (LAContext) throws -> T) rethrows -> T? {
        try lock.withLockUnchecked { context in
            try body(context)
        }
    }
}
