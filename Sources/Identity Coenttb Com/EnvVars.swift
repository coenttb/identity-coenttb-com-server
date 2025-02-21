//
//  File.swift
//  rule-law-server
//
//  Created by Coen ten Thije Boonkkamp on 30/08/2024.
//

import Coenttb_Vapor
import EnvironmentVariables
import Mailgun
import Postgres
import Coenttb_Identity_Provider

extension EnvVars {
    public var postgres: Postgres.Client.EnvVars {
        .init(
            databaseUrl: self["DATABASE_URL"]!
        )
    }

    public var mailgun: Mailgun.Client.EnvVars? {
        guard
            let baseUrl = self.url("MAILGUN_BASE_URL"),
            let apiKey = self["MAILGUN_PRIVATE_API_KEY"],
            let domain = self["MAILGUN_DOMAIN"]
        else {
            return nil
        }

        return .init(
            baseUrl: baseUrl,
            apiKey: .init(rawValue: apiKey),
            domain: try! .init(domain)
        )
    }
}

extension EnvVars {
    public var mailgunCompanyEmail: EmailAddress? {
        self["MAILGUN_COMPANY_EMAIL"].flatMap(EmailAddress.init(rawValue:))
    }
}

extension EnvVars {
    public var demoName: String? {
        self["DEMO_NAME"]
    }

    public var demoEmail: EmailAddress? {
        self["DEMO_EMAIL"].flatMap(EmailAddress.init(rawValue:))
    }

    public var demoPassword: String? {
        self["DEMO_PASSWORD"]
    }

    public var demoNewsletterEmail: EmailAddress? {
        self["DEMO_NEWSLETTER_EMAIL"].flatMap(EmailAddress.init(rawValue:))
    }

    public var demoStripeCustomerId: String? {
        self["DEMO_STRIPE_CUSTOMER_ID"]
    }

    public var monthlyBlogSubscriptionPriceId: String? {
        self["MONTHLY_BLOG_SUBSCRIPTION_PRICE_ID"]
    }

    public var monthlyBlogSubscriptionPriceLookupKey: String? {
        self["MONTHLY_BLOG_SUBSCRIPTION_PRICE_LOOKUP_KEY"]
    }
    
    public var newsletterAddress: EmailAddress? {
        self["NEWSLETTER_ADDRESS"].flatMap(EmailAddress.init(rawValue:))
    }

    public var companyName: String? {
        self["COMPANY_NAME"]
    }

    public var companyInfoEmailAddress: EmailAddress? {
        self["COMPANY_INFO_EMAIL_ADDRESS"].flatMap(EmailAddress.init(rawValue:))
    }

    public var companyXComHandle: String? {
        self["COMPANY_X_COM_HANDLE"]
    }

    public var companyGitHubHandle: String? {
        self["COMPANY_GITHUB_HANDLE"]
    }

    public var companyLinkedInHandle: String? {
        self["COMPANY_LINKEDIN_HANDLE"]
    }

    public var sessionCookieName: String? {
        self["SESSION_COOKIE_NAME"]
    }
}

extension BusinessDetails {
    package static let fromEnvVars: BusinessDetails = {
        @Dependency(\.envVars.mailgun?.domain) var domain
        
        @Dependencies.Dependency(\.envVars.companyName!) var businessName
        @Dependencies.Dependency(\.envVars.companyInfoEmailAddress!) var supportEmail
        @Dependencies.Dependency(\.envVars.companyInfoEmailAddress!) var fromEmail
        
        return BusinessDetails(
            name: businessName,
            supportEmail: supportEmail,
            fromEmail: fromEmail,
            primaryColor: .green550.withDarkColor(.green600)
        )
    }()
}
