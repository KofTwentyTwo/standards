# AI-assisted development policy

KofTwentyTwo uses AI coding agents (such as Claude Code) to plan, write, test, and
review code. This policy makes sure that doing so never lowers the bar: an agent is a
tool used by an accountable person, and its output goes through exactly the same gates
as anyone else's.

**Owner:** the maintainer · **Review:** every six months; this area changes fast.

## Accountability

**K22-AI-01 (MUST)** A human maintainer is accountable for every change, whoever or
whatever wrote it. The maintainer reads and understands AI-generated code before
merging it, exactly as if a stranger had submitted it.
*Why:* agents produce plausible code that can be subtly wrong or insecure.
*Verified by:* the review requirement of [`K22-SDLC-12`](sdlc.md#build).

**K22-AI-02 (MUST)** The DCO sign-off ([`K22-SDLC-13`](sdlc.md#build)) on an
AI-assisted commit is made by the human who takes responsibility for it. Substantial AI
contribution is disclosed with a `Co-Authored-By:` trailer naming the model, and in
the pull request description.
*Why:* honest provenance; an AI cannot certify the right to contribute.
*Verified by:* `pr / dco`; review.

## Agent permissions

**K22-AI-10 (MUST)** Agents work through pull requests only. They do not push to
`main`, approve or merge pull requests, create tags or releases, publish packages,
change rulesets or repository settings, or delete branches or repositories, unless the
maintainer explicitly approves that specific action at the time.
*Why:* an agent can be manipulated or simply mistaken; irreversible and
outward-facing actions stay with a person. *Verified by:* rulesets (no bypass actors,
[`K22-REPO-20`](../standards/repository.md)); agent permission configuration;
`K22-REPO-31` (workflows cannot approve pull requests).

**K22-AI-11 (MUST)** Agents run with the least privilege that lets them work: scoped
tokens, no access to signing identities, publishing credentials, password managers, or
production secrets, and a permission mode that requires confirmation for destructive
or outward-facing commands.
*Why:* limits the damage of a prompt injection or a bad plan. *Verified by:* agent
configuration review in the annual access review
([`K22-SEC-04`](security-program.md#accounts-and-access)).

**K22-AI-12 (MUST)** MCP servers, agent plugins, and skills are installed only from
sources the maintainer trusts, at pinned versions, after reviewing the tools and
permissions they expose. They are treated as dependencies under
[`K22-SEC-21`](security-program.md#development-environment).
*Why:* an agent extension runs with the agent's access. *Verified by:* annual review.

## Data and untrusted input

**K22-AI-20 (MUST)** Secrets, credentials, and personal data are never given to an AI
service: not pasted into prompts, not left in files an agent will read, not exposed in
environment variables an agent can print.
*Why:* prompts and context may be logged or retained outside your control.
*Verified by:* [`K22-SEC-10`](security-program.md#secrets-and-credentials); secret
scanning of agent-authored changes.

**K22-AI-21 (MUST)** Content an agent reads from outside the maintainer's own
instructions (web pages, issue and pull request text from others, dependency
documentation, tool output, files from downloads) is treated as data, never as
instructions. An agent that encounters instructions in such content does not follow
them.
*Why:* prompt injection is the agent-era equivalent of code injection.
*Verified by:* agent configuration; review of agent actions in the pull request.

## Quality of AI output

**K22-AI-30 (MUST)** AI-generated changes meet the same Definition of Done
([`K22-SDLC-20`](sdlc.md#verify)), including tests written in the same pull request.
Tests an agent writes must test behavior, not mirror the implementation.
*Why:* the most common failure of generated code is code that only looks finished.
*Verified by:* required checks; review.

**K22-AI-31 (MUST)** Every dependency an agent adds is verified to be the intended,
real package (publisher, repository, download history) before merge, in addition to
the [dependency standard](../standards/dependencies.md).
*Why:* agents can invent package names that attackers then register
("slopsquatting"). *Verified by:* `pr / dependency-review`; review.

**K22-AI-32 (MUST)** Agent output that reproduces third-party code verbatim is accepted
only if that code's license is compatible and attributed.
*Why:* the project's license must stay clean. *Verified by:* review.

## Repository instructions

**K22-AI-40 (SHOULD)** Each repository commits an agent instructions file (`CLAUDE.md`
and/or `AGENTS.md`) stating how to build, test, and lint, and the rules from these
standards that most often matter in that repository, and keeps it current.
*Why:* agents follow the project's conventions when the conventions are written down
where they look. *Verified by:* conformance checker (file present, warning only).

## AI in products

**K22-AI-50 (MUST)** A product that sends user data to an AI model documents which
provider and model, what data is sent and when, and how to turn the feature off; such
features are opt-in.
*Why:* users decide what leaves their machine. *Verified by:* product README; threat
model ([`K22-SEC-70`](security-program.md#data-protection)).
