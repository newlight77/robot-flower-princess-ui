# CI/CD Documentation

## Overview

This project uses **GitHub Actions** for continuous integration and continuous deployment. The CI/CD pipeline ensures code quality, runs comprehensive tests, enforces coverage thresholds, and automates builds and deployments.

## Pipeline Architecture

### Workflow File
- **Location**: `.github/workflows/ci.yml`
- **Triggers**:
  - Push to `main` or `develop` branches
  - Pull requests to `main` or `develop` branches

### Pipeline Stages

```
┌─────────────────┐
│  Code Analysis  │  ← Linting & static analysis
└────────┬────────┘
         │
    ┌────┴────┬────────┬────────┐
    ▼         ▼        ▼        ▼
┌────────┐ ┌──────┐ ┌──────┐ ┌────────┐
│ Unit   │ │ Use  │ │Widget│ │Feature │  ← Parallel test execution
│ Tests  │ │ Case │ │Tests │ │ Tests  │
└───┬────┘ └──┬───┘ └──┬───┘ └───┬────┘
    │         │        │         │
    └─────────┴────────┴─────────┘
              │
              ▼
    ┌──────────────────┐
    │ Code Coverage    │  ← Merge & analyze
    │ • Merge reports  │
    │ • Generate HTML  │
    │ • Check 80%      │
    │ • Upload Codecov │
    └────────┬─────────┘
             │
        ┌────┴────┐
        ▼         ▼
    ┌──────┐  ┌────────┐
    │ Web  │  │ Docker │  ← Build only if tests pass
    │Build │  │ Image  │     (main branch only)
    └──────┘  └────────┘
```

## Jobs

### 1. Test Jobs (Parallel Execution)

#### Unit Tests
- **Job Name**: `test-unit`
- **Purpose**: Test individual functions and classes
- **Test Path**: `test/unit/`
- **Runs on**: `ubuntu-latest`
- **Flutter Version**: 3.35.6 (stable)

**Steps**:
1. Checkout code
2. Setup Flutter environment
3. Install dependencies (`flutter pub get`)
4. Run unit tests with coverage
5. Upload coverage artifact

#### Use Case Tests
- **Job Name**: `test-use-case`
- **Purpose**: Test business logic and domain rules
- **Test Path**: `test/use_case/`
- **Configuration**: Same as unit tests

#### Widget Tests
- **Job Name**: `test-widget`
- **Purpose**: Test UI components
- **Test Path**: `test/widget/`
- **Configuration**: Same as unit tests

#### Feature Tests
- **Job Name**: `test-feature`
- **Purpose**: End-to-end scenario testing
- **Test Path**: `test/feature/`
- **Configuration**: Same as unit tests

### 2. Code Coverage Job

- **Job Name**: `code-coverage`
- **Purpose**: Merge coverage reports and enforce quality gates
- **Depends On**: All test jobs
- **Runs on**: `ubuntu-latest`

**Steps**:

1. **Download Coverage Artifacts**
   - Downloads all coverage reports from test jobs
   - Stored in `coverage-artifacts/` directory

2. **Merge Coverage Reports**
   - Uses `lcov` to merge all coverage files
   - Generates single comprehensive `lcov.info`
   - Calculates total coverage percentage

3. **Generate HTML Report**
   - Creates detailed HTML coverage report
   - Includes line-by-line coverage
   - Shows hit/miss statistics
   - Available as downloadable artifact (30-day retention)

4. **Coverage Threshold Check** ⚠️
   - **Threshold**: 80%
   - **Action**: Fails build if coverage < 80%
   - **Purpose**: Enforce code quality standards

5. **Upload to Codecov**
   - Automatic upload to Codecov.io
   - Track coverage trends over time
   - Visualize coverage changes

6. **Generate Job Summary**
   - Creates GitHub Actions summary
   - Shows coverage metrics
   - Displays test suite status
   - Provides links to reports

7. **PR Comment** (Pull Requests Only)
   - Posts coverage summary on PR
   - Shows pass/fail status
   - Links to detailed report

### 3. Build Jobs

#### Web Build
- **Job Name**: `build-web`
- **Depends On**: `code-coverage`
- **Runs On**: Push events only
- **Purpose**: Build production web application

**Steps**:
1. Checkout code
2. Setup Flutter
3. Install dependencies
4. Build web release (`flutter build web --release`)
5. Upload build artifacts

**Artifacts**:
- `build/web/` directory
- Retained for deployment

#### Docker Build
- **Job Name**: `docker`
- **Depends On**: `build-web`
- **Runs On**: Push to `main` branch only
- **Purpose**: Build Docker image for deployment

**Steps**:
1. Checkout code
2. Build Docker image with commit SHA tag

**Image Tag**: `robot-flower-princess:${{ github.sha }}`

## Coverage Reporting

### Coverage Threshold

**Target**: 80% line coverage

**Enforcement**:
- Build fails if coverage < 80%
- Prevents merging low-quality code
- Ensures comprehensive test coverage

**Adjusting Threshold**:

Edit `.github/workflows/ci.yml`:
```yaml
THRESHOLD=80  # Change to desired percentage
```

### Coverage Reports

#### 1. HTML Report (Downloadable)
- **Location**: Artifacts → `coverage-html-report`
- **Retention**: 30 days
- **Content**: Line-by-line coverage, statistics, file breakdown

#### 2. Codecov Integration
- **URL**: https://codecov.io
- **Features**:
  - Coverage trends over time
  - File-level coverage
  - Commit-by-commit comparison
  - Pull request comments

#### 3. PR Comments
Automatically posted on pull requests:

```markdown
## ✅ Test Coverage Report

**Total Coverage:** 85.3%
**Threshold:** 80%
**Status:** PASSED

| Test Suite | Status |
|------------|--------|
| Unit Tests | ✅ |
| Use Case Tests | ✅ |
| Widget Tests | ✅ |
| Feature Tests | ✅ |

[View detailed coverage report](...)
```

#### 4. Job Summary
Visible in GitHub Actions:
- Coverage percentage
- Threshold status
- Test suite breakdown
- Links to artifacts

## Running Locally

### Simulate Full CI Workflow

Run all test suites with coverage:
```bash
make test-coverage
```

This command:
1. Runs all 4 test suites with coverage
2. Merges coverage reports
3. Generates HTML report
4. Checks 80% threshold
5. Outputs detailed results

### View Coverage Report
```bash
# Generate and view HTML coverage
make coverage-html
open coverage/html/index.html
```

### Clean Coverage Artifacts
```bash
make coverage-clean
```

### Run Individual Test Suites
```bash
make test-unit        # Unit tests only
make test-use-case    # Use case tests only
make test-widget      # Widget tests only
make test-feature     # Feature tests only
make test-all-suites  # All suites with summary
```

## Branch Strategy

### Main Branch (`main`)
- **Protection**: Pull request required
- **CI Requirements**: All jobs must pass
- **Coverage**: Must meet 80% threshold
- **Deployment**: Triggers Docker build

### Develop Branch (`develop`)
- **Protection**: Pull request recommended
- **CI Requirements**: All jobs must pass
- **Coverage**: Must meet 80% threshold
- **Deployment**: Web build only (no Docker)

### Feature Branches
- **Naming**: `feature/*`, `fix/*`, `refactor/*`
- **CI Triggers**: On pull request
- **Requirements**: All tests must pass

## Environment Variables

### Required in GitHub Actions

No secrets required currently. Future considerations:

```yaml
# If deploying to cloud services
AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

# If using Codecov token (optional)
CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

# If deploying to Docker registry
DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

## Artifacts

### Coverage Artifacts (1-day retention)
- `unit-coverage` - Unit test coverage
- `use-case-coverage` - Use case test coverage
- `widget-coverage` - Widget test coverage
- `feature-coverage` - Feature test coverage

### Build Artifacts
- `coverage-html-report` (30 days) - HTML coverage report
- `web-build` - Production web build

## Monitoring & Notifications

### GitHub Actions Status
- View at: `https://github.com/{owner}/{repo}/actions`
- Shows all workflow runs
- Filterable by branch, status, actor

### Codecov Dashboard
- View at: `https://codecov.io/gh/{owner}/{repo}`
- Coverage trends
- File-level analysis
- Commit coverage

### PR Status Checks
Required checks before merge:
- ✅ Unit Tests
- ✅ Use Case Tests
- ✅ Widget Tests
- ✅ Feature Tests
- ✅ Code Coverage (80%+)
- ✅ Web Build

## Troubleshooting

### Job Failures

#### Tests Failing
```bash
# Run locally to reproduce
make test-all-suites

# Run specific suite
make test-unit
```

#### Coverage Below Threshold
```bash
# Check current coverage
make coverage-detail

# View HTML report to see uncovered lines
make coverage-html
open coverage/html/index.html
```

#### Build Failures
```bash
# Test build locally
flutter build web --release

# Check for dependency issues
flutter pub get
flutter pub outdated
```

### Common Issues

#### Issue: Flutter Version Mismatch
**Solution**: Update `.github/workflows/ci.yml` to match `pubspec.yaml`

#### Issue: Coverage Merge Fails
**Solution**: Ensure all test jobs completed successfully

#### Issue: Docker Build Fails
**Solution**: Test locally:
```bash
docker build -t robot-flower-princess:test .
docker run -p 8080:80 robot-flower-princess:test
```

#### Issue: Codecov Upload Fails
**Solution**:
- Check Codecov service status
- Verify repository is configured on Codecov
- Add `CODECOV_TOKEN` secret if private repo

## Performance Optimization

### Current Execution Times
- Unit Tests: ~30 seconds
- Use Case Tests: ~20 seconds
- Widget Tests: ~25 seconds
- Feature Tests: ~30 seconds
- Coverage Merge: ~10 seconds
- **Total**: ~2-3 minutes (parallel)

### Optimization Strategies

1. **Parallel Test Execution**: Tests run in parallel ✅
2. **Dependency Caching**: Cache Flutter SDK and dependencies
3. **Matrix Strategy**: Run tests across multiple Flutter versions
4. **Incremental Testing**: Only test changed files

### Future Improvements

```yaml
# Cache Flutter dependencies
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: ~/.pub-cache
    key: flutter-${{ runner.os }}-${{ hashFiles('pubspec.lock') }}

# Matrix testing
strategy:
  matrix:
    flutter-version: ['3.35.6', '3.36.0']
    os: [ubuntu-latest, macos-latest, windows-latest]
```

## Best Practices

### Code Quality
1. ✅ Write tests before pushing
2. ✅ Run `make test-coverage` locally
3. ✅ Ensure coverage meets threshold
4. ✅ Review coverage report for gaps
5. ✅ Fix linter warnings before commit

### Pull Requests
1. ✅ Create descriptive PR title
2. ✅ Wait for all checks to pass
3. ✅ Review coverage report comment
4. ✅ Address failing tests immediately
5. ✅ Keep PRs focused and small

### Deployment
1. ✅ Merge only after all checks pass
2. ✅ Monitor build artifacts
3. ✅ Verify Docker image builds (main only)
4. ✅ Test deployed application

## Continuous Deployment (Future)

### Planned CD Targets

#### Web Deployment
- **Target**: Firebase Hosting / Netlify
- **Trigger**: Push to `main`
- **Process**: Automatic deployment after successful build

#### Docker Registry
- **Target**: Docker Hub / GitHub Container Registry
- **Trigger**: Push to `main`
- **Process**: Publish Docker image

#### Mobile Deployment
- **Target**: App Store / Play Store
- **Trigger**: Git tag (e.g., `v1.0.0`)
- **Process**: Build and publish mobile apps

### Example CD Job (Future)

```yaml
deploy-web:
  name: Deploy to Firebase
  needs: [build-web]
  runs-on: ubuntu-latest
  if: github.ref == 'refs/heads/main'

  steps:
    - uses: actions/checkout@v5

    - name: Download web build
      uses: actions/download-artifact@v4
      with:
        name: web-build
        path: build/web

    - name: Deploy to Firebase
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: ${{ secrets.GITHUB_TOKEN }}
        firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
        channelId: live
```

## Security

### Secrets Management
- Store secrets in GitHub Secrets
- Never commit credentials
- Rotate secrets regularly
- Use least privilege principle

### Dependency Security
```bash
# Check for vulnerabilities
flutter pub outdated
dart pub audit

# Update dependencies
flutter pub upgrade
```

### Docker Security
- Use official Flutter base images
- Scan images for vulnerabilities
- Keep images minimal
- Update base images regularly

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Codecov Documentation](https://docs.codecov.com/)
- [LCOV Documentation](http://ltp.sourceforge.net/coverage/lcov.php)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2025-10-24 | 1.0 | Initial CI/CD pipeline with 80% coverage threshold |

---

**Maintained by**: Development Team
**Last Updated**: October 24, 2025
**Pipeline Version**: 1.0
