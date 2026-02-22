# Week 01 — Website Unreachable Triage (Lab)

# Ticket Case File

## Customer symptom
A user reported that the website wouldn’t load / seemed unreachable.

## Impact / Severity
For this lab, I treated the report as a potential user-impacting availability issue and verified service health using HTTPS (not just ping). I considered this a low-severity / unverified outage scenario until evidence confirmed whether the website was actually down.

## Hypothesis tree (initial)
- DNS issue (domain not resolving or inconsistent answers)
- HTTPS/TLS issue (handshake/cert problems)
- Routing/path issue (timeouts to the destination)
- ICMP blocked (ping/trace tools failing even if the site is up)

## Evidence Table

| Check | Command | Result | What it means | Proof file |
|---|---|---|---|---|
| Azure subscription context | `az account show -o table` | Subscription is enabled and default | I confirmed I was working in the correct Azure subscription context before creating resources | `evidence/raw/az-account-show.txt` |
| Ephemeral lab boundary | `az group create -n rg-lab-week01 -l southeastasia -o table` | Resource group created successfully | I created an isolated, easy-to-clean-up lab boundary for Week 1 | `evidence/raw/az-group-create.txt` |
| DNS (default resolver) | `nslookup example.com` | Returned A and AAAA records | DNS resolution worked from the default resolver | `evidence/raw/nslookup-default.txt` |
| DNS (Cloudflare resolver) | `nslookup example.com 1.1.1.1` | Returned the same A/AAAA records (order may differ) | DNS answers were consistent across resolvers | `evidence/raw/nslookup-1.1.1.1.txt` |
| HTTPS/TLS + HTTP | `curl -I -v --connect-timeout 5 --max-time 15 https://example.com` | TLS verified successfully and HTTP returned 200 | Website is reachable over HTTPS; TLS and HTTP are healthy | `evidence/raw/curl-https.txt` |
| ICMP reachability | `ping -c 4 example.com` | 100% packet loss | Ping failed, but this alone does not prove website downtime | `evidence/raw/ping.txt` |
| Path probing | `tracepath example.com` | No replies across hops | Trace probes likely blocked / not responding; does not contradict successful HTTPS | `evidence/raw/tracepath.txt` |
| Tooling constraint | `sudo tdnf install -y traceroute` / `tdnf install -y traceroute` | Install blocked (`no new privileges`, root required) | Cloud Shell prevented package installation, so I used `tracepath` instead | `evidence/raw/traceroute-install-failed.txt` |

## Diagnosis (evidence-based)
Based on my tests, the site is reachable over HTTPS (HTTP 200) and DNS resolution is consistent across resolvers. Ping/trace-style probes failing does not indicate downtime in this case (likely blocked), and my environment shows IPv6 “network unreachable” but IPv4 works.

## Fix / Mitigation
I did not apply any changes since the core service check (HTTPS) was already successful. My mitigation is documentation/education: use HTTP(S) as the primary availability test for websites, and treat ping/trace results as supplemental.

## Verification Notes
- HTTP proof: `< HTTP/2 200`
- TLS proof: `SSL certificate verify ok.`
- DNS proof: `nslookup example.com` and `nslookup example.com 1.1.1.1` returned the same A/AAAA records
- Additional note: `ping` showed 100% packet loss and `tracepath` showed no replies, which can happen when ICMP/trace probes are blocked even if HTTPS works.

## Decision Notes
I prioritized safe, no-change verification first (DNS → HTTPS/TLS → optional reachability tools). Since HTTPS returned a successful response, I did not escalate this as a real outage based only on ping/trace failures.

## Communication Updates

### First Update
Thank you for reporting this issue. I am currently investigating the website access problem and performing initial checks (DNS resolution and HTTPS reachability) from the test environment. I will provide the next update after the initial diagnostics are completed.

### Next Update
Initial checks have been completed. DNS resolution is successful from the test environment (both default resolver and 1.1.1.1), so the issue does not currently appear to be DNS-related. I am continuing basic reachability/HTTPS checks to isolate whether the problem is at the network, TLS, or application layer.

### Resolution Update
Based on the completed checks, DNS resolution is working normally and the issue appears to be beyond the DNS layer (service/HTTPS reachability). At this time, the site is still not consistently reachable from the test checks, so this case is being treated as an investigation/escalation scenario. Please retry access after some time while monitoring continues, and we will provide another update if the status changes.

## Cleanup Proof (end of week)
At the end of Week 1, I will delete `rg-lab-week01` and capture proof that it no longer exists.