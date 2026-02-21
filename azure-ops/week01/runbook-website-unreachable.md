# Runbook: Website Unreachable Triage

## Purpose
This runbook is a procedure that guides the triage process when a website is unreachable. It helps identify possible causes of the issue and prioritize the next actions. It also helps expedite resolution while minimizing technical misconfigurations by using safe checks and collecting evidence from test results and factual outputs before conducting a specific step.

## Scope / Assumptions
- This runbook covers triaging reports that a website is unreachable or appears down from the user’s perspective.
- Checks in this runbook are performed from the current test environment (for this lab, Azure Cloud Shell), so results may vary across networks, locations, or vantage points.
- HTTP(S) response and TLS verification are treated as the primary availability signals for website triage, while ping and traceroute/tracepath results are supplemental only.
- This runbook prioritizes safe, non-invasive verification and evidence collection before making changes or escalating the issue.

## L1 Safe Checks
1. Confirm the exact URL/domain (human error check)
   - Inspect for typo in the domain, wrong path, and wrong scheme (`http` vs `https`).

2. Check DNS resolution (core check)
   - Use `nslookup <domain.com>` to verify that the domain resolves.

3. Check HTTP(S)/TLS (primary service check)
   - Use `curl -I -v --connect-timeout 5 --max-time 15 https://<domain.com>` to test HTTP response and TLS behavior.

4. Run ICMP ping (supplemental)
   - Use `ping -c 4 <domain.com>` as an additional reachability signal only.

5. Run traceroute/tracepath (supplemental)
   - Use `traceroute <domain.com>` if available, or `tracepath <domain.com>` as an alternative to observe path behavior.

## L1 Interpretation Guide
- If the URL/domain/path/scheme (`http` vs `https`) is incorrect, the issue may be caused by user input error. Correct the target and retest before deeper troubleshooting.
- If DNS resolution succeeds, the domain appears resolvable from the current test environment. Continue with HTTP(S)/TLS checks to verify actual web service reachability.
- If DNS resolution fails, this may indicate a DNS-related issue (resolver, domain, or DNS configuration problem). Collect the DNS output and continue with DNS-focused checks.
- If HTTP(S) responds successfully and TLS verification succeeds, the website is reachable from the current test environment. Do not conclude website downtime based only on ping/traceroute failure.
- If HTTP(S)/TLS fails, this may indicate a TLS/certificate/handshake issue or a service-side issue depending on the exact error output. Collect the exact response/error and continue to deeper checks.
- If ping or traceroute/tracepath fails, treat it as supplemental evidence only. Probe failure alone does not confirm website downtime because ICMP/trace probes may be blocked, filtered, or rate-limited.
- If HTTP(S) times out or the connection is refused, this may indicate a service/path/network issue from the current vantage point. Proceed to L2 checks and escalate if the behavior is consistent across repeated tests or multiple environments.

## L2 Deeper Checks

L2 Deeper Checks are performed when L1 checks do not resolve the issue. The goal is to isolate the exact failure point, collect evidence, and determine whether the issue is related to DNS, TLS/certificate, HTTP/application behavior, network path, or Azure configuration before making changes or escalating.

- **Endpoint Reachability (outside-in)**
  - Validate website reachability using a browser and/or command-line tools (for example, `curl`) from a test client.
  - Identify whether the failure occurs during DNS lookup, TCP connection, TLS handshake, or HTTP response.
  - Capture the exact error message, timestamp, and test output/screenshot as evidence.
  - This helps determine the layer where the failure begins.

- **DNS Resolution Validation**
  - Verify that the domain resolves and confirm that it points to the expected IP address or endpoint.
  - Record resolver results and any DNS errors (such as timeout or NXDOMAIN).
  - Capture timestamps and resolver output as evidence.
  - This helps isolate DNS-related issues from application/server issues.

- **TLS / Certificate Checks (HTTPS)**
  - Validate HTTPS behavior, including TLS handshake success, certificate validity dates, hostname match, and certificate chain.
  - Record any browser warnings or command-line TLS/certificate errors.
  - Capture timestamps and relevant certificate details as evidence.
  - This helps identify TLS/certificate-related causes of website access failures.

- **HTTP Response Behavior**
  - Check the returned HTTP status code and observe response behavior (for example, redirects, timeouts, or error pages).
  - Record status code, response time, redirect behavior, and any visible error details.
  - Capture timestamps and test output as evidence.
  - This helps determine whether the issue is related to the web application, reverse proxy, or backend dependency.

- **Azure Read-Only Checks**
  - Review Azure Service Health for active incidents or advisories affecting the service and region.
  - Review Resource Health of the affected resource for degraded or unavailable status.
  - Review Activity Log for recent operations or configuration changes near the incident start time.
  - Review Azure Monitor / Log Analytics / application logs for errors, request failures, or latency spikes.
  - Perform a read-only review of relevant network/security configuration (such as NSG/UDR/load balancer/gateway settings) for possible traffic blocking or routing issues.
  - Capture timestamps, status values, screenshots, and log snippets as evidence.
  - This helps identify platform, resource, configuration, or change-related causes without making changes.

- **Recent Change Correlation**
  - Check whether a deployment, DNS update, certificate renewal, restart, scaling action, or network/security rule change occurred before the issue started.
  - Compare change timestamps with the incident start time.
  - Record the change type, affected resource, timestamp, and change source (if available).
  - This helps identify change-related causes and possible rollback candidates.

### Decision Points
- If DNS resolution fails, investigate DNS records, zone configuration, and propagation.
- If DNS succeeds but TLS fails, investigate certificate validity, hostname binding, and certificate chain.
- If TLS succeeds but HTTP returns 5xx errors or timeouts, investigate application/backend health and logs.
- If Azure read-only checks show incidents, degraded resource health, or related errors, continue investigation in the affected Azure service/resource path.
- If a recent change correlates with incident start time, validate whether rollback is appropriate.
- If evidence is insufficient or remediation is high-risk, escalate with an evidence packet.

### Safety Rule
- Perform read-only checks first before attempting any configuration changes.
- Any change must include a documented reason, rollback plan, and verification step.

## Escalation Triggers

Escalate to a higher support tier or specialized team when one or more of the following conditions are met:

- The issue persists after L1 and L2 checks are completed and the root cause is still not confirmed.
- The next remediation step requires high-risk or out-of-scope changes (for example, DNS updates, certificate replacement/renewal, NSG/UDR/firewall rule changes, or production service restart/redeploy).
- Azure Service Health or Resource Health indicates a platform or resource issue that is relevant to the observed symptoms.
- A recent change correlates with the incident timeline and rollback or owner action requires approval or access from another team.
- The impact is widespread or severity is high (for example, multiple users/locations are affected or a business-critical service is unavailable).
- Required logs, telemetry, or resource access are unavailable, preventing evidence-based troubleshooting and safe diagnosis.

### Before Escalating
Prepare and attach an evidence packet that includes:
- Exact error message(s)
- Timestamps (with timezone)
- L1 and L2 checks performed
- What passed and what failed
- Command outputs, screenshots, and/or log snippets
- Suspected failing layer (DNS, TLS, HTTP/application, network path, Azure resource/platform)
- Current impact summary (users/locations/service affected, if known)

### Safety Note
- Do not perform high-risk remediation while waiting for escalation approval unless explicitly authorized and a rollback plan is prepared.

## Escalation Packet

When escalation is required, prepare an escalation packet that contains enough verified context and evidence for the receiving team to continue troubleshooting without repeating basic checks.

### Required Contents
- **Incident Summary**
  - Reported symptom
  - Affected URL/domain/service
  - Time observed (with timezone)
  - Current status (ongoing, intermittent, resolved, or unknown)

- **Impact / Severity**
  - Affected users/locations (if known)
  - Business impact (if known)
  - Environment (production, test, lab/simulation)
  - Severity level (if applicable)

- **Evidence Collected**
  - Exact error message(s)
  - Timestamps
  - Command outputs
  - Screenshots
  - Log snippets
  - Azure health/resource status observations (if checked)

- **L1/L2 Checks Performed**
  - List of checks completed
  - What passed and what failed
  - Any checks not performed and why

- **Current Findings / Working Theory**
  - Suspected failing layer (DNS, TLS, HTTP/application, network path, Azure resource/platform)
  - Hypotheses should be labeled as unconfirmed unless supported by evidence
  - Known limitations or access constraints

- **Recent Change Correlation**
  - Relevant deployments, DNS changes, certificate changes, restarts, or network/security changes
  - Timestamps and affected resources
  - Whether rollback is being considered

- **Requested Action (Escalation Ask)**
  - Specific action requested from the receiving team (for example, review backend logs, validate gateway config, approve rollback, or investigate application errors)
  - Urgency/priority if applicable

- **Attachments / References**
  - Screenshot filenames, logs, output files, dashboard links, ticket/case ID, or related runbook references

### Packet Quality Rules
- Separate verified facts from assumptions.
- Include timestamps and timezone for key observations.
- Do not omit failed checks, repeated behavior, or uncertainties.
- Keep the packet concise but complete enough for immediate handoff.

> If no escalation is required for the current case, document **“Not applicable (no escalation required)”** in the case file/evidence notes.

## Rollback

Rollback defines how to safely return to a known-good state if a remediation change causes additional issues, does not resolve the problem, or introduces unexpected side effects.

### Rollback Principles
- Do not perform changes without identifying a rollback option first.
- Prefer low-risk, reversible changes before high-impact actions.
- Document the current state before applying any change (screenshots, config values, timestamps).
- Ensure the rollback owner/approver is identified when required.

### Before Making a Change
Document the following:
- **Change to be made** (what will be changed)
- **Reason for change** (what evidence supports it)
- **Expected outcome** (what should improve)
- **Rollback method** (how to revert)
- **Rollback trigger** (what condition means rollback should occur)
- **Verification steps** (how success/failure will be confirmed after the change)

### Rollback Triggers
Initiate rollback when one or more of the following occur:
- The issue persists after the change and evidence does not show improvement.
- Service behavior worsens after the change (for example, new errors, increased failures, longer timeouts).
- A new customer-facing impact is introduced.
- Monitoring/logs indicate regression after the change.
- The change was applied incorrectly or produced unexpected side effects.

### Rollback Execution (General)
- Revert the modified setting/resource to the last known-good configuration.
- Record the rollback action, timestamp, and operator/owner.
- Capture relevant outputs/screenshots after rollback.
- Re-run verification checks to confirm post-rollback state.

### Rollback Safety Note
- If rollback itself is high-risk or requires elevated access/approval, escalate and attach the evidence packet before proceeding.

> If no remediation changes were made in the current case, document **“Not applicable (no changes made)”** in the case file/evidence notes.

## Verification

Verification confirms whether the service is reachable and stable after triage findings, remediation, or rollback. Resolution should be based on evidence rather than assumption.

### Verification Goals
- Confirm the intended service behavior is restored (or confirm the observed status in a triage-only case).
- Confirm no new issue was introduced.
- Record objective evidence of the final state.

### Verification Checks
- **URL/Target Verification**
  - Reconfirm the exact URL/domain/path/scheme being tested.

- **DNS Verification**
  - Re-run DNS resolution checks and confirm expected resolver behavior.

- **HTTP(S)/TLS Verification (Primary)**
  - Re-test HTTP(S) response and TLS behavior using browser and/or command-line tools (for example, `curl`).
  - Confirm response status, TLS behavior, and observed error/no-error state.

- **Repeatability Check**
  - Repeat the primary test at least once after a short interval to confirm consistent behavior (especially for intermittent symptoms).

- **Cross-Environment / Cross-Vantage Check (if available)**
  - Validate from another client/network/location when possible to reduce false conclusions from a single vantage point.

- **Monitoring / Logs Verification (if applicable)**
  - Confirm errors/failures/latency return to expected levels after remediation or rollback.

### Verification Evidence to Record
- Final test timestamp(s) with timezone
- Exact command outputs and/or screenshots
- HTTP status result and TLS observation
- What changed (if any) and whether rollback was used
- Final triage outcome (resolved, not reproduced, escalated, monitoring, or no issue found)

### Final Verification Notes
- Ping and traceroute/tracepath results remain supplemental and should not override successful HTTP(S)/TLS verification for website availability conclusions.
- If results are inconsistent across environments or repeated tests, document the inconsistency and continue investigation or escalate as appropriate.