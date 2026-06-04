# Scale Secure Action

Automatically run advanced, AI-driven API security and functionality tests directly from your GitHub Actions CI/CD pipelines.

## Usage

Create a `scalesecure-tests.json` file in the root of your repository (you can generate this from the Scale Secure dashboard). 
Then, add this action to your `.github/workflows/main.yml`:

```yaml
name: CI
on: [push, pull_request]

jobs:
  security-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Run Scale Secure API Tests
        uses: <your-github-username>/scalesecure-action@v1
        with:
          api-key: ${{ secrets.SCALESECURE_API_KEY }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `api-key` | **Yes** | | Your private Scale Secure API Key (store this in GitHub Secrets). |
| `config-file` | No | `scalesecure-tests.json` | Path to your configuration JSON file. |
| `github-token` | No | | Providing `secrets.GITHUB_TOKEN` allows the action to automatically post a detailed vulnerability report as a comment on Pull Requests. |
