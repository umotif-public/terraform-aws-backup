# Running Terratest

## Install Golang

If you are on MacOS and have homebrew installed:
`brew install go`

## Full Test Run

To run all of the tests from this directory:
`go test -v -timeout 30m`

## Specific Test Runs

`go test -v -timeout 30m -run [function_name]`

## Stop on first failure

`go test -v -timeout 30m -failfast`
