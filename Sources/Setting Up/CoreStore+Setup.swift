//
//  CoreStore+Setup.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import CoreData
#if USE_FRAMEWORKS
    import GCDKit
#endif


// MARK: - CoreStore

public extension CoreStore {
    
    /**
     Returns the `defaultStack`'s model version. The version string is the same as the name of the version-specific .xcdatamodeld file.
     */
    public static var modelVersion: String {
        
        return self.defaultStack.modelVersion
    }
    
    /**
     Returns the entity name-to-class type mapping from the `defaultStack`'s model.
     */
    public static var entityTypesByName: [String: NSManagedObject.Type] {
        
        return self.defaultStack.entityTypesByName
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from `defaultStack`'s model.
     */
    public static func entityDescriptionForType(type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return self.defaultStack.entityDescriptionForType(type)
    }
    
    /**
     Creates an `SQLiteStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     try CoreStore.addStorageAndWait()
     ```
     
     - returns: the local SQLite storage added to the `defaultStack`
     */
    public static func addStorageAndWait() throws -> SQLiteStore {
        
        return try self.defaultStack.addStorageAndWait(SQLiteStore)
    }
    
    /**
     Creates a `StorageInterface` of the specified store type with default values and adds it to the `defaultStack`. This method blocks until completion.
     ```
     try CoreStore.addStorageAndWait(InMemoryStore)
     ```
     
     - parameter storeType: the `StorageInterface` type
     - returns: the `StorageInterface` added to the `defaultStack`
     */
    public static func addStorageAndWait<T: StorageInterface where T: DefaultInitializableStore>(storeType: T.Type) throws -> T {
        
        return try self.defaultStack.addStorageAndWait(storeType.init())
    }
    
    /**
     Adds a `StorageInterface` to the `defaultStack` and blocks until completion.
     ```
     try CoreStore.addStorageAndWait(InMemoryStore(configuration: "Config1"))
     ```
     
     - parameter storage: the `StorageInterface`
     - returns: the `StorageInterface` added to the `defaultStack`
     */
    public static func addStorageAndWait<T: StorageInterface>(storage: T) throws -> T {
        
        return try self.defaultStack.addStorageAndWait(storage)
    }
    
    /**
     Creates a `LocalStorageface` of the specified store type with default values and adds it to the `defaultStack`. This method blocks until completion.
     ```
     try CoreStore.addStorageAndWait(SQLiteStore)
     ```
     
     - parameter storeType: the `LocalStorageface` type
     - returns: the local storage added to the `defaultStack`
     */
    public static func addStorageAndWait<T: LocalStorage where T: DefaultInitializableStore>(storageType: T.Type) throws -> T {
        
        return try self.defaultStack.addStorageAndWait(storageType.init())
    }
    
    /**
     Adds a `LocalStorage` to the `defaultStack` and blocks until completion.
     ```
     try CoreStore.addStorageAndWait(SQLiteStore(configuration: "Config1"))
     ```
     
     - parameter storage: the local storage
     - returns: the local storage added to the `defaultStack`
     */
    public static func addStorageAndWait<T: LocalStorage>(storage: T) throws -> T {
        
        return try self.defaultStack.addStorageAndWait(storage)
    }
    
    
    // MARK: Deprecated
    
    /**
     Deprecated. Use `addStorageAndWait(_:)` by passing a `InMemoryStore` instance.
     */
    @available(*, deprecated=2.0.0, obsoleted=2.0.0, message="Use addStorageAndWait(_:) by passing an InMemoryStore instance.")
    public static func addInMemoryStoreAndWait(configuration configuration: String? = nil) throws -> NSPersistentStore {
        
        return try self.defaultStack.addInMemoryStoreAndWait(configuration: configuration)
    }
    
    /**
     Deprecated. Use `addStorageAndWait(_:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use addStorageAndWait(_:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public static func addSQLiteStoreAndWait(fileName fileName: String, configuration: String? = nil, resetStoreOnModelMismatch: Bool = false) throws -> NSPersistentStore {
        
        return try self.defaultStack.addSQLiteStoreAndWait(
            fileName: fileName,
            configuration: configuration,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch
        )
    }
    
    /**
     Deprecated. Use `addStorageAndWait(_:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use addStorageAndWait(_:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public static func addSQLiteStoreAndWait(fileURL fileURL: NSURL = LegacySQLiteStore.legacyDefaultFileURL, configuration: String? = nil, resetStoreOnModelMismatch: Bool = false) throws -> NSPersistentStore {
        
        return try self.defaultStack.addSQLiteStoreAndWait(
            fileURL: fileURL,
            configuration: configuration,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch
        )
    }
}
