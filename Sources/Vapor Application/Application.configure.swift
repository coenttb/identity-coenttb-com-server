// api-rule-law-server

import Coenttb_Identity_Provider
import Identity_Coenttb_Com
import Coenttb_Vapor
import Coenttb_Fluent
import JWT

extension Application {
    package static func configure(app: Vapor.Application) async throws {
        @Dependency(\.envVars) var envVars
        
        app.databases.use(.postgres, as: .psql)
        
        app.migrations.add(Coenttb_Identity_Provider.Database.Migration())
        
        if envVars.appEnv == .development {
            try await app.autoRevert()
        }
        
        try await app.autoMigrate()
        
        try await Application.configure(
            app: app,
            httpsRedirect: envVars.httpsRedirect,
            canonicalHost: envVars.canonicalHost,
            allowedInsecureHosts: envVars.allowedInsecureHosts,
            baseUrl: envVars.baseUrl
        )
        
        try await app.jwt.keys.add(ecdsa: ES256PrivateKey.init(pem: envVars["JWT_PRIVATE_KEY"]!))
        
        app.middleware.use(Identity.Provider.Middleware())
        
        @Dependency(\.identity.provider.router) var router
        
        app.mount(router, use: Identity.Provider.API.response)
    }
}

