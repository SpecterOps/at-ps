# Adversary Tactics: PowerShell
__This course material is no longer maintained and is being provided as-is.__

SpecterOps recently decommissioned our PowerShell course and rather than letting it collect dust, we wanted to offer it up to the community for free in the spirit of our [commitment to transparency](https://posts.specterops.io/a-push-toward-transparency-c385a0dd1e34).

We are extremely grateful for all of our students who were able to attend the course in person. Those students not only received this material, but they benefited from an extensive lab environment, live instructor demos, and individualized instructor feedback.

## Reproduction and Redistribution
All code is licensed under the GPLv3 license. We kindly ask that if you choose to reproduce or redistribute any of this material, that you credit SpecterOps accordingly.

## Why are we no longer offering the course?
With the advent of strong PowerShell security features, at one point, the team made a conscious decision to "diversify our offensive portfolio" which, at the time, was comprised of, predominantly, PowerShell code. Focusing our efforts on [rebuilding much](https://posts.specterops.io/ghostpack-d835018c5fc4) of [our tooling](https://posts.specterops.io/introducing-sharpsploit-a-c-post-exploitation-library-5c7be5f16c51) in [.NET](https://posts.specterops.io/entering-a-covenant-net-command-and-control-e11038bcf462) was a natural option as we were already comfortable utilizing .NET classes based on our collective PowerShell knowledge, the relative ease with which C# code was developed, and considering a general lack of security optics within the CLR (at the time).

So with the refocusing of our tradecraft and capability development, work on PowerShell was de-prioritized. Additionally, with the inclusion of the core security improvements made in [PowerShell v5](https://devblogs.microsoft.com/powershell/powershell-the-blue-team/), from our perspective, there have been only gradual security improvements made, predominantly, to address security vulnerabilities affecting [security boundaries](https://www.microsoft.com/en-us/msrc/windows-security-servicing-criteria). Considering all of this, we feel as though the course material in its current state offers broad coverage of the most important security features available in PowerShell.

Does this imply that PowerShell is no longer relevant to attackers and defenders? Absolutely not. PowerShell is still used extremely heavily in the wild and defenders need to be equipped to detect all of the tactics they may employ. SpecterOps continues to use PowerShell heavily internally for its intended purpose, automation.

Do we still use PowerShell during operations? Certainly. It is used when it makes sense to do so and when it has been determined that the risk to getting caught is minimal. Such a risk assessment should ideally be made in employing *any* post-exploitation actions. Our apprehension of using PowerShell for offense, though, speaks volumes to the great strides that have been made by Microsoft to improve its security footprint even in the face of the multitude of bypasses we cover in this course material.

Again, to reiterate: PowerShell use by attackers is not going anywhere and defenders need to know how to detect its use. This material is being released for free to facilitate detection.

## Miscellaneous Notes
* __Some of the course material may flag antivirus__. For example, PowerView.ps1 is a common offender. Be mindful of the environment in which you download this material.
* The Active Directory lab material was designed to run in a live domain environment. That lab environment was provided for in-person course offerings. That lab environment will not be made available.

## Enjoy!
