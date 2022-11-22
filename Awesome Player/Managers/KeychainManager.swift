//
//  KeychainManager.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/17/22.
//

import Foundation

class KeychainManager {
	let service = KeyChainParameters.service
	let account = KeyChainParameters.account

	enum KeychainError: Error {
		// Attempted read for an item that does not exist.
		case itemNotFound
		// Attempted save to override an existing item.
		// Use update instead of save to update existing items
		case duplicateItem
		// A read of an item in any format other than Data
		case invalidItemFormat
		// Any operation result status than errSecSuccess
		case unexpectedStatus(OSStatus)
	}

	func setToken(token: Data) throws {
		print("Started setting Token")
		let query: [String: AnyObject] = [
			// attrs to identify item
			kSecAttrService as String: self.service as AnyObject,
			kSecAttrAccount as String: self.account as AnyObject,
			kSecClass as String: kSecClassGenericPassword,
			// data to save
			kSecValueData as String: token as AnyObject
		]
		// adding items to keychain
		let status = SecItemAdd(query as CFDictionary, nil)
		// it's a duplicate
		if status == errSecDuplicateItem {
			// updating key
			do {
				try self.updateToken(token: token)
			} catch {
				print(error)
			}
			throw KeychainError.duplicateItem
		}
		// trowing error if failed to save data
		guard status == errSecSuccess else {
			print("Error setting Token")
			throw KeychainError.unexpectedStatus(status)
		}
		print("Finished setting Token")
	}

	func getToken() throws -> String {
		print("Started getting Token")
		let query: [String: AnyObject] = [
			// kSecAttrService,  kSecAttrAccount, and kSecClass
			// uniquely identify the item to read in Keychain
			kSecAttrService as String: self.service as AnyObject,
			kSecAttrAccount as String: self.account as AnyObject,
			kSecClass as String: kSecClassGenericPassword,
			// kSecMatchLimitOne indicates keychain should read
			// only the most recent item matching this query
			kSecMatchLimit as String: kSecMatchLimitOne,
			// kSecReturnData is set to kCFBooleanTrue in order
			// to retrieve the data for the item
			kSecReturnData as String: kCFBooleanTrue
		]
		// SecItemCopyMatching will attempt to copy the item
		// identified by query to the reference itemCopy
		var itemCopy: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
		// errSecItemNotFound is a special status indicating the
		// read item does not exist. Throw itemNotFound so the
		// client can determine whether or not to handle
		// this case
		guard status != errSecItemNotFound else {
			throw KeychainError.itemNotFound
		}
		// Any status other than errSecSuccess indicates the
		// read operation failed.
		guard status == errSecSuccess else {
			throw KeychainError.unexpectedStatus(status)
		}
		// This implementation of KeychainInterface requires all
		// items to be saved and read as Data. Otherwise,
		// invalidItemFormat is thrown
		guard let authKeyData = itemCopy as? Data else {
			throw KeychainError.invalidItemFormat
		}
		let authKey = String(decoding: authKeyData, as: UTF8.self)
		print("Finished getting Token")
		return authKey
	}

	func updateToken(token: Data) throws {
		print("Started updating Token")
		let query: [String: AnyObject] = [
			// kSecAttrService,  kSecAttrAccount, and kSecClass
			// uniquely identify the item to update in Keychain
			kSecAttrService as String: self.service as AnyObject,
			kSecAttrAccount as String: self.account as AnyObject,
			kSecClass as String: kSecClassGenericPassword
		]
		// attributes is passed to SecItemUpdate with
		// kSecValueData as the updated item value
		let attributes: [String: AnyObject] = [
			kSecValueData as String: token as AnyObject
		]
		// SecItemUpdate attempts to update the item identified
		// by query, overriding the previous value
		let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
		// errSecItemNotFound is a special status indicating the
		// item to update does not exist. Throw itemNotFound so
		// the client can determine whether or not to handle
		// this as an error
		guard status != errSecItemNotFound else {
			throw KeychainError.itemNotFound
		}
		// Any status other than errSecSuccess indicates the
		// update operation failed.
		guard status == errSecSuccess else {
			throw KeychainError.unexpectedStatus(status)
		}
		print("Finished updating Token")
	}

	func deleteToken() throws {
		print("Started deleting Token")
		let query: [String: AnyObject] = [
			// kSecAttrService,  kSecAttrAccount, and kSecClass
			// uniquely identify the item to delete in Keychain
			kSecAttrService as String: self.service as AnyObject,
			kSecAttrAccount as String: self.account as AnyObject,
			kSecClass as String: kSecClassGenericPassword
		]
		// SecItemDelete attempts to perform a delete operation
		// for the item identified by query. The status indicates
		// if the operation succeeded or failed.
		let status = SecItemDelete(query as CFDictionary)
		// Any status other than errSecSuccess indicates the
		// delete operation failed.
		guard status == errSecSuccess else {
			throw KeychainError.unexpectedStatus(status)
		}
		print("Finished deleting Token")
	}
}
