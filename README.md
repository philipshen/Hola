# Hola

## Introduction

Hola is a tool for automated integration testing in iOS. You can use it to send requests from an iOS device or simulator to locally-running backend. It is a work in progress.

## Setting Up

1. Run HolaServer. The server ID will be displayed in the title and in the logs.
2. Edit the scheme of HolaTester (or whatever client you want to use) and create a new environment variable with key `holaServerIdentifier` to the server ID
3. Run your client

## Plans

Features planned include: 

* A way to cache sets of responses during testing and test against them later, a la [vcr](https://github.com/vcr/vcr)
* General, arbitrary proxying
* Ability to mock responses as needed by tests, to make it easier to isolate pieces of functionality being tested
