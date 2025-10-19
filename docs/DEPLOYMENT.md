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

GitHub Actions workflow is included in `.github/workflows/ci.yml`

### Triggers
- Push to main/develop branches
- Pull requests

### Steps
1. Run tests
2. Analyze code
3. Build for web
4. Build Docker image (main branch only)

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
