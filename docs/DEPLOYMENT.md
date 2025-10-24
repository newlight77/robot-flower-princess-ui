# Deployment Guide

## Docker Deployment

### Build Docker Image
```bash
docker build -t robot-flower-princess:latest .
```

### Run Container
```bash
docker run -p 8080:80   -e API_BASE_URL=http://your-api-url   robot-flower-princess:latest
```

### Using Docker Compose
```bash
docker-compose up -d
```

## Web Deployment

### Build for Production
```bash
flutter build web --release
```

The build output will be in `build/web/`

### Deploy to Static Hosting

#### Netlify
1. Connect your repository
2. Build command: `flutter build web --release`
3. Publish directory: `build/web`

#### Vercel
1. Import your repository
2. Framework: Other
3. Build command: `flutter build web --release`
4. Output directory: `build/web`

#### Firebase Hosting
```bash
firebase init hosting
firebase deploy
```

#### GitHub Pages
```bash
flutter build web --release --base-href "/repository-name/"
# Push build/web to gh-pages branch
```

## Mobile Deployment

### Android

#### Build APK
```bash
flutter build apk --release
```

#### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS

#### Build IPA
```bash
flutter build ios --release
```

#### Archive for App Store
```bash
flutter build ipa --release
```

## Environment Variables

Create `.env` file:
```
API_BASE_URL=https://your-production-api.com
APP_ENV=production
```

## CI/CD

This project uses **GitHub Actions** for continuous integration and deployment.

### Overview
- **Workflow File**: `.github/workflows/ci.yml`
- **Test Suites**: 4 parallel test suites (unit, use case, widget, feature)
- **Coverage Threshold**: 80% minimum required
- **Quality Gates**: Automatic build failure if coverage < 80%

### Automated Processes
1. ✅ Run all test suites in parallel
2. ✅ Merge coverage reports
3. ✅ Enforce 80% coverage threshold
4. ✅ Build web application
5. ✅ Build Docker image (main branch only)
6. ✅ Upload to Codecov
7. ✅ Generate coverage reports

**For detailed CI/CD documentation**, see [CI_CD.md](CI_CD.md)

## Monitoring

Consider setting up:
- Error tracking (Sentry, Crashlytics)
- Analytics (Google Analytics, Firebase Analytics)
- Performance monitoring

## Security

1. Use HTTPS for API communication
2. Set appropriate CORS headers on backend
3. Validate all user inputs
4. Keep dependencies updated
5. Regularly scan for vulnerabilities
6. Use secrets management for credentials
7. Keep Docker images updated

### Security Best Practices
```bash
# Check for security vulnerabilities
flutter pub outdated
dart pub audit

# Update dependencies
flutter pub upgrade

# Scan Docker images
docker scan robot-flower-princess:latest
```

## Related Documentation

- [CI/CD Pipeline](CI_CD.md) - Automated testing and deployment
- [Testing Strategy](TESTING_STRATEGY.md) - Comprehensive testing approach
- [Architecture](ARCHITECTURE.md) - System design and structure
- [API Integration](API.md) - Backend API documentation

---

**Last Updated**: October 24, 2025
**Version**: 1.1
