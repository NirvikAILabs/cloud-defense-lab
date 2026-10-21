"""Scans the Terraform in this folder (or another one) with Checkov and reports
which lab's flaws are fixed. Run: python check.py   (or: python check.py solution)

Needs Checkov: pip install checkov"""

import json
import shutil
import subprocess
import sys

LABS = [
    ("Storage", {
        "CKV_AWS_70": "Bucket policy doesn't allow everyone",
        "CKV_AWS_53": "Public ACLs blocked",
        "CKV_AWS_54": "Public bucket policies blocked",
        "CKV_AWS_55": "Public ACLs ignored",
        "CKV_AWS_56": "Public buckets restricted",
        "CKV2_AWS_6": "Every bucket has a public access block",
        "CKV_AWS_21": "Versioning on, so files can be recovered",
    }),
    ("Identity", {
        "CKV_AWS_273": "No IAM users with long-lived keys",
        "CKV_AWS_40": "No policies attached straight to users",
        "CKV_AWS_62": "No full-admin (*:*) policies",
        "CKV_AWS_63": "No wildcard actions",
    }),
    ("Network", {
        "CKV_AWS_24": "SSH not open to the internet",
        "CKV_AWS_25": "RDP not open to the internet",
        "CKV_AWS_260": "No wide-open port ranges (port 80 from anywhere)",
        "CKV_AWS_79": "IMDSv2 required on the server",
        "CKV_AWS_17": "Database not publicly accessible",
        "CKV_AWS_16": "Database storage encrypted",
    }),
    ("Logging", {
        "CKV_AWS_67": "CloudTrail covers every region",
        "CKV_AWS_36": "CloudTrail log file validation on",
        "CKV_AWS_35": "CloudTrail logs encrypted with your key",
    }),
    ("CI federation", {
        "CKV_AWS_358": "GitHub trust limited to one repository and branch",
        "CKV_AWS_274": "Deploy role isn't AdministratorAccess",
    }),
]


def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else "."
    if not shutil.which("checkov"):
        sys.exit("Checkov isn't installed. Run: pip install checkov")
    ids = ",".join(check for _, checks in LABS for check in checks)
    run = subprocess.run(
        ["checkov", "-d", folder, "--framework", "terraform", "--check", ids, "-o", "json", "--quiet", "--skip-download"],
        capture_output=True,
        text=True,
    )
    try:
        report = json.loads(run.stdout)
    except json.JSONDecodeError:
        sys.exit(f"Checkov didn't return a report:\n{run.stderr or run.stdout}")
    report = report[0] if isinstance(report, list) else report
    failed = {}
    for finding in report.get("results", {}).get("failed_checks", []):
        failed.setdefault(finding["check_id"], []).append(finding["resource"])

    total = passed = 0
    width = max(len(name) for _, checks in LABS for name in checks.values())
    for lab, checks in LABS:
        print(f"\n{lab}")
        for check, name in checks.items():
            total += 1
            where = failed.get(check)
            if where:
                print(f"  ✗ {name.ljust(width)}  {check}: {', '.join(sorted(set(where)))}")
            else:
                passed += 1
                print(f"  ✓ {name.ljust(width)}  fixed")
    print(f"\n{passed} of {total} checks pass.")


if __name__ == "__main__":
    main()
