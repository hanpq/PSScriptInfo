# Changelog for PSScriptInfo

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Implemented new CI/CD pipeline

## [1.3.11] - 2022-10-26

### fixed

- Change indent level from two to four for psscriptinfo comment block

## [1.3.10] - 2021-12-13

### changed

- Built with updated release pipeline

## [1.3.9] - 2021-04-11

### added

- When updating PSScriptInfo that is not on the first line. The updated PSScriptBlock will now be inserted at the same line number 

### fixed

- Fixed an issue when the PSScriptInfo was not on the first line, the line before and after the PSScriptBlock would join as strings

## [1.3.5] - 2021-04-03

### fixed

- Updated script functions with new psscriptinfo format

## [1.3.4] - 2021-04-03

### fixed

- Updated function script files with new psscriptinfo format

## [1.3.2] - 2021-04-03

### fixed

- Updated function scripts with new pscriptinfo format

## [1.3.1] - 2021-04-03

### added

- Added support for legacy psscriptinfo blocks

## [1.3.0] - 2021-04-01

### removed

- Removed signature from all script files due to certificate validation issue

## [1.1.0] - 2021-03-30

### added

- PSGallery release

## [1.0.0] - 2021-03-01

### other

- First version
