# Week 1 Teach-Back Recording Script

## Intro
Hi, this is my Week 1 teach-back recording for my cloud support practice pack.

This week, I worked on a simulated website unreachability issue in a simulated environment using `example.com` as a safe domain for triage practice.

## Week 1 Goal
My goal this week was to identify possible causes of a reported website unreachability issue using an evidence-first strategy.

I also practiced using safe, read-only checks first so I would not disrupt an actual system while troubleshooting.

## What I Completed
For Week 1, I completed the following:
- Ticket Case File (to summarize the troubleshooting process)
- Runbook (to organize possible checks, assumptions, and expected outputs)
- Draw.io diagram (to visualize the troubleshooting flow)
- Evidence compilation (to prove that I truthfully performed the checks)

## What I Checked (Evidence)
I first checked the DNS layer using `nslookup` on the simulated domain.

From this check, I found that the domain resolved successfully and returned IP addresses, specifically IPv4 and IPv6 addresses. This suggests that DNS resolution was working during my test.

Next, I checked the HTTP(S)/TLS layer using the `curl` command.

From this check, the TLS handshake was successful, and the domain returned an HTTP 200 response. This indicates that the server successfully responded to my HTTP request during testing.

I also ran `ping` and `tracepath` as supplemental checks. These probes did not return successful replies, but this did not override the successful HTTPS result because ICMP and trace probes can be blocked or filtered.

## What I Learned
This week, I learned the difference between a DNS issue and a web server or HTTP(S) issue.

I also learned that I need to collect evidence first before deciding on a troubleshooting strategy.

Another important lesson is to avoid overclaiming that I can fix the issue immediately without complete verification.

I also learned to perform safe, read-only checks first to avoid making the issue worse.

## Closing
This is my Week 1 teach-back.

Based on the evidence from my current test environment, I could not reproduce a website outage, and this week helped me practice structured troubleshooting, evidence-first thinking, and clearer support communication.