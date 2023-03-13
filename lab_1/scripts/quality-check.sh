echo "Running code quality check..."
cd ../shop-angular-cloudfront
npm run test
npm run lint
npm run e2e
npm run lint:format