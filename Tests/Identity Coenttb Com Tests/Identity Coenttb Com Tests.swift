//
//  File.swift
//  rule-legal-server
//
//  Created by Coen ten Thije Boonkkamp on 23/12/2024.
//

import Foundation
import Testing
import Coenttb_Vapor
//import DependenciesTestSupport
import API_Rule_Law_Router
import Server_Client
import Server_Client_Live
import API_Rule_Law
import DependenciesTestSupport
import Mailgun

@Suite(
    "API Rule Law Tests",
    .dependency(\.mailgunClient, Mailgun.Client.liveValue)
)
struct APIRuleLawTests {
    @Test("All cases should have valid index values")
    func test1() async throws {
        @Dependency(\.mailgunClient) var mailgunClient
        
        
        
        print(String(describing: response))
    }
}
