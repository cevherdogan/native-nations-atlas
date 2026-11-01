# AA integration boundary — v0.3.4

This is a **non-operative adapter contract**, not a second identity service. Reuse the existing ScholarFlow Auth Store v0.3.1 / Auth Web v0.4.0 (coaching-derived) after verifying its live interface and exact authorization protocol. Do not trust browser roles, query parameters, or localStorage for authorization.

## Safe integration
1. Preserve the public atlas and all existing navigation. Do not redirect public heritage pages to login.
2. Stage the external AA service independently under `/auth-web` and confirm its own login, forced password change, logout, session expiration, CSRF and server-side entitlement checks.
3. Build a **server-side** PHP bridge from the verified Auth Web session interface. Require deny-by-default for protected endpoints; verify origin, session and role on each request. No unverified protocol is assumed here.
4. Keep identity/session databases, secrets, audit and seeded identities outside the atlas public webroot and Git. Provision unique one-time credentials through the existing auth management tooling; never ship default passwords.
5. Validate positive and negative role tests, then switch on protected endpoints via an explicit activation gate; support rollback without changing public atlas files.

## Role semantics
Guest: public atlas only. Reader: signed-in reading. Researcher: private collections. Contributor: submit drafts. Reviewer: review drafts. Editor: publish approved content. Admin: access policy and audits. Permissions are **planned**, not enforced by this static release.

## Gamified access experience
Show visit/session count, remaining time, progress, achievements and learning journeys only using **server-verified** access information. Progress indicators must not imply Indigenous cultural knowledge has been earned or authenticated. No points for sacred knowledge or restricted places. Consent is required for behavioral tracking.

## Activation gate
`AA_ACTIVATE=YES` is reserved for a future release once the real bridge, session contract and security tests are integrated. This package does **not** enable AA and does not claim working login.
