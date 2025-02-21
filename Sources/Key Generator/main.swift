//
//  File.swift
//  api-rule-law-server
//
//  Created by Coen ten Thije Boonkkamp on 10/02/2025.
//

import Foundation
import JWT

let key = ES256PrivateKey()
print("Private key PEM:")
print(key.pemRepresentation)
print("\nPublic key PEM:")
print(key.publicKey.pemRepresentation)
