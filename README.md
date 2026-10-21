# Cloud Defense lab

The AWS infrastructure for a small app ("Pantry Cloud"), written in Terraform, with **deliberate security flaws**. It's the lab for the free course [Cloud Defense](https://ready.nirvik.ai/c/cloud-defense) on Nirvik Ready.

**You don't need an AWS account for the main labs:** you scan the code, fix it and rescan. The optional sandbox labs in the course show how to deploy the fixed version to your own AWS account safely.

> **Never apply the files in this folder to a real AWS account.** They're insecure on purpose. The fixed version is in `solution/`.

## Start

**In your browser:** click **Code → Codespaces → Create codespace**. Checkov, Terraform and the AWS CLI are installed for you.

**On your machine:** you need Python 3.10 or newer, then:

```bash
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install checkov
python check.py
```

`check.py` scans the Terraform here with [Checkov](https://www.checkov.io/) and reports each lab's checks. At the start, none pass. Fix the files, rerun it, and watch them turn green. Compare with `python check.py solution`.

## The labs

| Lab           | File         | Flaws                                                                                                                 |
| ------------- | ------------ | --------------------------------------------------------------------------------------------------------------------- |
| Storage       | `storage.tf` | A bucket policy that lets anyone do anything; public access block switched off; no versioning                         |
| Identity      | `iam.tf`     | An IAM user with an access key and full admin rights                                                                  |
| Network       | `network.tf` | SSH and every port open to the internet; IMDSv1 allowed; a public, unencrypted database with its password in the code |
| Logging       | `logging.tf` | A CloudTrail trail in one region, unencrypted, without integrity checks                                               |
| CI federation | `ci.tf`      | GitHub Actions can deploy from any repository, as admin                                                               |

The checker can't see everything: it doesn't flag the database password written in `network.tf`. The course shows how to fix that too (let AWS manage it in Secrets Manager).

## Other scanners

Try the same code with [Trivy](https://trivy.dev/) (`trivy config .`) or [KICS](https://kics.io/): different tools find different things, and none finds everything.

## License

MIT. Made by Nirvik AI Labs for learning.
