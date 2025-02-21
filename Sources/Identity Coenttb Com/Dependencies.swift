//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 04-01-2024.
//

import Coenttb_Vapor
import Mailgun
import Coenttb_Com_Shared
import Coenttb_Identity_Provider

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Identity.Provider.Configuration: @retroactive DependencyKey {
    public static var liveValue: Identity.Provider.Configuration {
        @Dependency(\.coenttb.identity.provider) var provider
        @Dependency(\.coenttb.website.router) var router
        @Dependency(\.envVars.appEnv) var appEnv
        @Dependency(\.logger) var logger
        
        let currentUserName = ""
        
        let cookies: Identity.CookiesConfiguration = switch appEnv {
        case .development, .testing: .development
        default: .live
        }

        return .init(
            provider: .init(
                baseURL: provider.baseURL,
                domain: nil,
                issuer: nil,
                cookies: cookies,
                router: provider.router,
                client: .live(
                    sendVerificationEmail: { email, token in
                        @Dependencies.Dependency(\.mailgunClient?.messages.send) var sendEmail
                        @Dependencies.Dependency(\.fireAndForget) var fireAndForget
                        @Dependencies.Dependency(\.envVars.companyName!) var businessName
                        @Dependencies.Dependency(\.envVars.companyInfoEmailAddress!) var supportEmail
                        @Dependencies.Dependency(\.envVars.companyInfoEmailAddress!) var fromEmail
                        
                        do {
                            let response = try await sendEmail?(
                                Email.requestEmailVerification(
                                    verificationUrl: router.identity.view.url(for: .create(.verify(.init(token: token, email: email.rawValue)))),
                                    businessName: "\(businessName)",
                                    supportEmail: supportEmail,
                                    from: fromEmail,
                                    to: email,
                                    primaryColor: .green550.withDarkColor(.green600)
                                )
                            )
                            
                            if let response {
                                logger.info("Email sent successfully: \(response)")
                            }
                            
                        } catch {
                            logger.error("Failed to send verification email: \(error)")
                            throw error
                        }
                    },
                    sendPasswordResetEmail: { email, token in
                        @Dependencies.Dependency(\.mailgunClient?.messages.send) var sendEmail
                        @Dependencies.Dependency(\.fireAndForget) var fireAndForget
                        
                        await fireAndForget {
                            let response = try await sendEmail?(
                                Email(
                                    business: .fromEnvVars,
                                    passwordEmail: .reset(
                                        .request(
                                            .init(
                                                resetUrl: router.identity.view.url(for: .password(.reset(.confirm(.init(token: token, newPassword: ""))))),
                                                userName: currentUserName,
                                                userEmail: email
                                            )
                                        )
                                    )
                                )
                            )
                            
                            if let response {
                                logger.info("Email sent successfully: \(response)")
                            }
                        }
                    },
                    sendPasswordChangeNotification: { email in
                        @Dependencies.Dependency(\.mailgunClient?.messages.send) var sendEmail
                        @Dependencies.Dependency(\.fireAndForget) var fireAndForget
                        
                        await fireAndForget {
                            let response = try await sendEmail?(
                                Email(
                                    business: .fromEnvVars,
                                    passwordEmail: .change(.notification(.init(userName: currentUserName, userEmail: email)))
                                )
                            )
                            
                            if let response {
                                logger.info("Email sent successfully: \(response)")
                            }
                        }
                    },
                    sendEmailChangeConfirmation: { currentEmail, newEmail, token in
                        @Dependencies.Dependency(\.mailgunClient?.messages.send) var sendEmail
                        @Dependencies.Dependency(\.fireAndForget) var fireAndForget
                        
                        await fireAndForget {
                            let response = try await sendEmail?(
                                Email(
                                    business: .fromEnvVars,
                                    emailChange: .confirmation(
                                        .request(
                                            .init(
                                                verificationURL: router.identity.view.url(for: .email(.change(.confirm(.init(token: token))))),
                                                currentEmail: currentEmail,
                                                newEmail: newEmail,
                                                userName: currentUserName
                                            )
                                        )
                                    )
                                )
                            )
                            
                            if let response {
                                logger.info("Email sent successfully: \(response)")
                            }
                        }
                    },
                    sendEmailChangeRequestNotification: { currentEmail, newEmail in
                        @Dependencies.Dependency(\.mailgunClient?.messages.send) var sendEmail
                        @Dependencies.Dependency(\.fireAndForget) var fireAndForget
                        
                        await fireAndForget {
                            let response = try await sendEmail?(
                                Email(
                                    business: .fromEnvVars,
                                    emailChange: .request(
                                        .notification(
                                            .init(
                                                currentEmail: currentEmail,
                                                newEmail: newEmail,
                                                userName: "currentUserName"
                                            )
                                        )
                                    )
                                )
                            )
                            
                            if let response {
                                logger.info("Email sent successfully: \(response)")
                            }
                        }
                    },
                    onEmailChangeSuccess: { currentEmail, newEmail in
                        @Dependencies.Dependency(\.mailgunClient?.messages.send) var sendEmail
                        @Dependencies.Dependency(\.fireAndForget) var fireAndForget
                        @Dependencies.Dependency(\.database) var database
                        
                        let currentUserName = ""
                        
                        await fireAndForget {
                            try await withThrowingTaskGroup(of: Void.self) { [sendEmail, currentEmail, newEmail, currentUserName] group in
                                
                                group.addTask {
                                    @Dependency(\.logger) var logger
                                    let response = try await sendEmail?(
                                        Email(
                                            business: .fromEnvVars,
                                            emailChange: .confirmation(
                                                .notification(
                                                    .currentEmail(
                                                        .init(
                                                            currentEmail: currentEmail,
                                                            newEmail: newEmail,
                                                            userName: currentUserName
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                    
                                    if let response {
                                        logger.info("Email sent successfully: \(response)")
                                    }
                                }
                                group.addTask {
                                    @Dependency(\.logger) var logger
                                    if let response = try await sendEmail?(
                                        Email(
                                            business: .fromEnvVars,
                                            emailChange: .confirmation(
                                                .notification(
                                                    .newEmail(
                                                        .init(
                                                            currentEmail: currentEmail,
                                                            newEmail: newEmail,
                                                            userName: currentUserName
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    ) {
                                        logger.info("Email sent successfully: \(response)")
                                    }
                                }
                                
                                try await group.waitForAll()
                            }
                        }
                        
                    },
                    sendDeletionRequestNotification: { email in
                        
                    },
                    sendDeletionConfirmationNotification: {
                        email in
                    }
                )
            )
        )
    }
}

extension EnvVars: @retroactive DependencyKey {
    public static var liveValue: Self {
        var localDevelopment: URL? {
#if DEBUG
            @Dependency(\.projectRoot) var projectRoot
            return projectRoot.appendingPathComponent(".env.development")
#else
            return nil
#endif
        }
        
        return try! EnvVars.live(localDevelopment: localDevelopment)
    }
}

extension LanguagesKey: @retroactive DependencyKey {
    public static var liveValue: Set<Language> {
        @Dependency(\.envVars.languages) var languages
        return languages.map(Set.init) ?? .init([.english])
    }
}


extension ProjectRootKey: @retroactive DependencyKey {
    public static var liveValue: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

extension SQLPostgresConfigurationKey: @retroactive DependencyKey {
    public static var liveValue: SQLPostgresConfiguration {
        
        @Dependency(\.envVars.emergencyMode) var emergencyMode
        @Dependency(\.envVars.postgres.databaseUrl) var postgresDatabaseUrl
        
        return .liveValue(
            emergencyMode: emergencyMode,
            postgresDatabaseUrl: postgresDatabaseUrl)
    }
}

extension Logger: @retroactive DependencyKey {
    public static var liveValue: Logger  {
        @Dependency(\.envVars) var envVars
        let logger = Logger(label: ProcessInfo.processInfo.processName) { _ in
            CoenttbLogHandler(label: "identity.coenttb.com", logLevel: envVars.logLevel ?? .trace, metadataProvider: nil)
        }
        return logger
    }
}

extension Mailgun.Client: @retroactive DependencyKey {
    public static var liveValue: Mailgun.AuthenticatedClient? {
        @Dependency(\.envVars) var envVars
        
        guard
            let baseURL = envVars.mailgun?.baseUrl,
            let apiKey = envVars.mailgun?.apiKey,
            let domain = envVars.mailgun?.domain
        else {
            return nil
        }
        
        return Mailgun.Client.live(
            apiKey: apiKey,
            baseUrl: baseURL,
            domain: domain
        )
    }
}
