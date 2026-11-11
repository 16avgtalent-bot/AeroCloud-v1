PROJECT := AeroCloud.xcodeproj
SCHEME := AeroCloud
DESTINATION := generic/platform=iOS Simulator

.PHONY: bootstrap generate open build test clean

bootstrap:
	@command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
	@test -f Config/Secrets.xcconfig || cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig

generate:
	xcodegen generate

open: generate
	open $(PROJECT)

build: generate
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		CODE_SIGNING_ALLOWED=NO build

test:
	swift test --package-path Packages/AeroCloudCore

clean:
	rm -rf build DerivedData Packages/*/.build
