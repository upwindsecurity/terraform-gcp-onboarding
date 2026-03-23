# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## 1.0.0 (2026-03-23)

### ⚠ BREAKING CHANGES

* creates a shared module `_shared`, and moves API enablement there.
  Further resources will be moved across in stages.

* chore(AG-3628): remove APIs to rely on external script, move project based roles to shared

* chore(AG-3628): move remaining resources to shared module - secrets and WIF

* chore(AG-3628): add labels by default to applicable resources

* chore(AG-3628): remove unused API variables, other var cleanup

* feat(AG-3628): add folder deployment option

* chore(AG-3628): update READMEs

* chore(AG-3628): add dummy secret with user defined labels for later use

* chore(AG-3628): add missing moved block for compute agent minimal permissions

* chore(AG-3628): add moved blocks for secrets
* **AG-2890:** this upgrades the Upwind GCP deployments
    to use Workload Identity Federation instead of directly
    using Service Accounts by creating a private key.

    An identity pool is created and trust is configured with the
    Upwind AWS account. It will be necessary for a customer to
    provide a credential configuration for WIF after creation
    using the gcloud command specified in the documentation, and
    uploading this to Upwind.

* feat!(AG-3628): support gcp onboarding at project multiproject and folder level ([#48](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/48)) ([0f67983](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/0f679830a63198dd6b6c8186c49bc81725cbd302))

### Features

* **AG-2890:** GCP Workload Identity Federation ([#1](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/1)) ([8480477](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/84804775c3f9898942e41fe1694622bb7d98a5d6))
* **AG-2921:** add variable to control WIF project ([#6](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/6)) ([820f1e9](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/820f1e91d6c5e7f24ab094f3c287d6a70aca2468))
* **AG-2923:** reduce storageAdmin role to only required permissions ([#9](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/9)) ([307cf6a](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/307cf6a67e5f8fafff8673a9fcaafa934eea6a77))
* **AG-2991:** add storage bucket read permissions to management account ([#19](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/19)) ([feafa66](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/feafa667ea14968515d10e9f6a8942297e9b72f8))
* **AG-3170:** update for ME region ([#33](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/33)) ([cdea817](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/cdea8176432dd63f3105623687b4f18ac2bcf64f))
* **AG-3214:** remove unnecessary IAM write role as all IAM creation is now handled within onboarding ([#35](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/35)) ([396e034](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/396e034406a3d3f0e6032c0287a65a45c949ee1d))
* **AG2922:** remove token creator bindings, allow cloudscanner to impersonate scaler ([#8](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/8)) ([a5c88a1](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/a5c88a1467e64f4dc9519ba46aca70ae6cd18360))
* update release workflow and CI/CD pipeline ([#3](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/3)) ([7c182b1](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/7c182b187eef7c4f93050b6a0a7d66207f7ac398))

### Bug Fixes

* add missing permissions for certain cases ([#51](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/51)) ([72d260c](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/72d260c920e8e05659829b5c6c687483c5304244))
* **AG-0:** add deprecation warning to old project module, support private region in WIF ([6e13ba2](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/6e13ba23be10a255174e44d6fbe2c60a00aed52b))
* **AG-0:** add run.jobs.update permission for stack update operations ([#54](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/54)) ([dbf6c0c](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/dbf6c0cf7e5bbd84fa1865dec423f436373f88f4))
* **AG-2928:** move disks.createSnapshot permission, fix empty workload ([#12](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/12)) ([6d015e8](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/6d015e8bb06eb466a1cb853a2871c7447306b1ee))
* **AG-2937:** fix role name for snapshot reader/writer ([#14](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/14)) ([0d538cf](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/0d538cfcf3d374c53b82f57f5977d91e52919a96))
* **AG-2954:** permissions fixes for scaling and scanning, reorganisation of roles ([#16](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/16)) ([21a17e1](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/21a17e18e96123b32bfb2531e6355ad340fb8f46))
* **AG-2990:** fix role conditions to use extract with template instead of regex ([#21](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/21)) ([f4bf2a3](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/f4bf2a3bf6780543797c8f8e4cb92c34c3dbf611))
* **AG-3041:** add missing instanceGroupManagers.update permission for updating scanners ([#26](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/26)) ([cad9199](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/cad919929a5d6b48a8d46cd9d91685f8fb016753))
* **AG-3476:** add folderViewer permissions to management account ([#39](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/39)) ([42eb32a](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/42eb32a8fed388328580760bc0a09e7e4e4d9176))
* **AG-3477:** add asset viewer role ([#41](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/41)) ([6f23011](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/6f23011259021df99a42308258b82df9c44e9df5))
* **AG-3477:** missing cloud asset role for customer asset collector ([#43](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/43)) ([77703d7](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/77703d77fe45bbfe1fee27746896d86ce7512378))
* **AG-4397:** remove unused local provider ([#59](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/59)) ([965a14b](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/965a14b9b0a7e644caf24f09b53f6ea8763d9b03))
* **AG-4576:** use workload_identity_trusted_account for WIF authentication ([#64](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/64)) ([67964f4](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/67964f4141aeadd5d808769ef64a1c724653de8f))
* **AG-4659:** Scaler lambda requires compute.instances.delete when it falls back to directly removing vm insances in the clean up job ([#69](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/69)) ([4cf0950](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/4cf095091c6434652fb06e9b899ad2db0e888261))
* **AG-4672:** inherit root module provider in gcp onboarding terraform ([#71](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/71)) ([6cc8125](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/6cc81250006308768642d2859c4cd8a12de6613b)), closes [#68](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/68)
* **AG-4849:** add dependencies for roles to avoid race conditions ([#73](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/73)) ([e12c9ba](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/e12c9ba8aa49fadd042aa1f324558df57beed13a))
* clean up whitespace and formatting in workflow and documentation files ([#4](https://github.com/upwindsecurity/terraform-gcp-onboarding/issues/4)) ([3c1bd15](https://github.com/upwindsecurity/terraform-gcp-onboarding/commit/3c1bd152f350702878a625a7e68f683c0b439f89))

## [3.1.8](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v3.1.7...v3.1.8) (2026-03-20)

## [3.1.7](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v3.1.6...v3.1.7) (2026-03-02)

### Bug Fixes

* **AG-4672:** inherit root module provider in gcp onboarding terraform ([#71](https://github.com/upwindsecurity/terraform-google-onboarding/issues/71)) ([6cc8125](https://github.com/upwindsecurity/terraform-google-onboarding/commit/6cc81250006308768642d2859c4cd8a12de6613b)), closes [#68](https://github.com/upwindsecurity/terraform-google-onboarding/issues/68)

## [3.1.6](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v3.1.5...v3.1.6) (2026-02-25)

### Bug Fixes

* **AG-4659:** Scaler lambda requires compute.instances.delete when it falls back to directly removing vm insances in the clean up job ([#69](https://github.com/upwindsecurity/terraform-google-onboarding/issues/69)) ([4cf0950](https://github.com/upwindsecurity/terraform-google-onboarding/commit/4cf095091c6434652fb06e9b899ad2db0e888261))

## [3.1.5](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v3.1.4...v3.1.5) (2026-02-12)

### Bug Fixes

* **AG-4576:** use workload_identity_trusted_account for WIF authentication ([#64](https://github.com/upwindsecurity/terraform-google-onboarding/issues/64)) ([67964f4](https://github.com/upwindsecurity/terraform-google-onboarding/commit/67964f4141aeadd5d808769ef64a1c724653de8f))

## [3.1.4](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v3.1.3...v3.1.4) (2026-01-15)

### Bug Fixes

* **AG-4397:** remove unused local provider ([#59](https://github.com/upwindsecurity/terraform-google-onboarding/issues/59)) ([37ff000](https://github.com/upwindsecurity/terraform-google-onboarding/commit/37ff0001b295f39bbe6444d7ef9467f07713fdf3))

## [3.1.3](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v3.1.2...v3.1.3) (2025-12-19)

### Bug Fixes

* **AG-0:** add deprecation warning to old project module, support private region in WIF ([8272cf4](https://github.com/upwindsecurity/terraform-google-onboarding/commit/8272cf40cd5a1f93614ac87dee82f354726c778f))

## [3.1.2](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v3.1.1...v3.1.2) (2025-11-14)

### Bug Fixes

* **AG-0:** add run.jobs.update permission for stack update operations ([#54](https://github.com/upwindsecurity/terraform-google-onboarding/issues/54)) ([acb0278](https://github.com/upwindsecurity/terraform-google-onboarding/commit/acb0278e91939a40cf27fef140d586faab304569))

## [3.1.1](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v3.1.0...v3.1.1) (2025-11-14)

### Bug Fixes

* add missing permissions for certain cases ([#51](https://github.com/upwindsecurity/terraform-google-onboarding/issues/51)) ([41c4793](https://github.com/upwindsecurity/terraform-google-onboarding/commit/41c47931675eb5e1ae56554a2d4c05fee0dca3c0))

## [3.0.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.7.6...v3.0.0) (2025-09-12)

### ⚠ BREAKING CHANGES

* creates a shared module `_shared`, and moves API enablement there.
  Further resources will be moved across in stages.

* chore(AG-3628): remove APIs to rely on external script, move project based roles to shared

* chore(AG-3628): move remaining resources to shared module - secrets and WIF

* chore(AG-3628): add labels by default to applicable resources

* chore(AG-3628): remove unused API variables, other var cleanup

* feat(AG-3628): add folder deployment option

* chore(AG-3628): update READMEs

* chore(AG-3628): add dummy secret with user defined labels for later use

* chore(AG-3628): add missing moved block for compute agent minimal permissions

* chore(AG-3628): add moved blocks for secrets

* feat!(AG-3628): support gcp onboarding at project multiproject and folder level ([#48](https://github.com/upwindsecurity/terraform-google-onboarding/issues/48)) ([0f966f5](https://github.com/upwindsecurity/terraform-google-onboarding/commit/0f966f5276715f5ae21311ab0125531d299cf36f))

## [2.7.4](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.7.3...v2.7.4) (2025-08-19)

### Bug Fixes

* **AG-3477:** missing cloud asset role for customer asset collector ([#43](https://github.com/upwindsecurity/terraform-google-onboarding/issues/43)) ([e157832](https://github.com/upwindsecurity/terraform-google-onboarding/commit/e1578328d6540c3a4bf6e9bf9e7afdfd23ea3086))

## [2.7.3](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.7.2...v2.7.3) (2025-08-12)

### Bug Fixes

* **AG-3477:** add asset viewer role ([#41](https://github.com/upwindsecurity/terraform-google-onboarding/issues/41)) ([a5d5d31](https://github.com/upwindsecurity/terraform-google-onboarding/commit/a5d5d31e0a9c6a8aff9559d85bd5ebea1596e73e))

## [2.7.2](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.7.1...v2.7.2) (2025-08-12)

### Bug Fixes

* **AG-3476:** add folderViewer permissions to management account ([#39](https://github.com/upwindsecurity/terraform-google-onboarding/issues/39)) ([b50810f](https://github.com/upwindsecurity/terraform-google-onboarding/commit/b50810f5db1462bf1247a62505b9cac20a6bb414))

## [2.7.1](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.7.0...v2.7.1) (2025-07-23)

### Bug Fixes

* **AG-3232:** add output for workload identity pool provider full path ([#36](https://github.com/upwindsecurity/terraform-google-onboarding/issues/36)) ([98a7da5](https://github.com/upwindsecurity/terraform-google-onboarding/commit/98a7da512a6613c756c0269c85a1ee27beb9ba78))

## [2.7.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.6.0...v2.7.0) (2025-07-23)

### Features

* **AG-3214:** remove unnecessary IAM write role as all IAM creation is now handled within onboarding ([#35](https://github.com/upwindsecurity/terraform-google-onboarding/issues/35)) ([ebb2202](https://github.com/upwindsecurity/terraform-google-onboarding/commit/ebb2202155a6005897675d31d533bd4077c6fb5a))

## [2.6.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.5.3...v2.6.0) (2025-07-18)

### Features

* **AG-3170:** update for ME region ([#33](https://github.com/upwindsecurity/terraform-google-onboarding/issues/33)) ([2cb8170](https://github.com/upwindsecurity/terraform-google-onboarding/commit/2cb81702ccddf84a784c4373f5b48dc45aa23c35))

## [2.5.3](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.5.2...v2.5.3) (2025-07-01)

### Bug Fixes

* **AG-3041:** add missing instanceGroupManagers.update permission for updating scanners ([#26](https://github.com/upwindsecurity/terraform-google-onboarding/issues/26)) ([49a345b](https://github.com/upwindsecurity/terraform-google-onboarding/commit/49a345bc631aebca17850ec116b17c48872ecc48))

## [2.5.1](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.5.0...v2.5.1) (2025-06-26)

### Bug Fixes

* **AG-2990:** fix role conditions to use extract with template instead of regex ([#21](https://github.com/upwindsecurity/terraform-google-onboarding/issues/21)) ([c588dc9](https://github.com/upwindsecurity/terraform-google-onboarding/commit/c588dc9b4e2b806d53533a588e7534c8ee0d1288))

## [2.5.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.4.3...v2.5.0) (2025-06-26)

### Features

* **AG-2991:** add storage bucket read permissions to management account ([#19](https://github.com/upwindsecurity/terraform-google-onboarding/issues/19)) ([f60be49](https://github.com/upwindsecurity/terraform-google-onboarding/commit/f60be49ef4f6213af50e30675f1e67673e831205))

## [2.4.3](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.4.2...v2.4.3) (2025-06-23)

### Bug Fixes

* **AG-2954:** permissions fixes for scaling and scanning, reorganisation of roles ([#16](https://github.com/upwindsecurity/terraform-google-onboarding/issues/16)) ([0e8bdac](https://github.com/upwindsecurity/terraform-google-onboarding/commit/0e8bdac89be5e9792e8d156a72ea234859936fb5))

## [2.4.2](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.4.1...v2.4.2) (2025-06-18)

### Bug Fixes

* **AG-2937:** fix role name for snapshot reader/writer ([#14](https://github.com/upwindsecurity/terraform-google-onboarding/issues/14)) ([650d41e](https://github.com/upwindsecurity/terraform-google-onboarding/commit/650d41e0017ea8edb40490a231cdf16831185c15))

## [2.4.1](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.4.0...v2.4.1) (2025-06-18)

### Bug Fixes

* **AG-2928:** move disks.createSnapshot permission, fix empty workload ([#12](https://github.com/upwindsecurity/terraform-google-onboarding/issues/12)) ([c03e6ef](https://github.com/upwindsecurity/terraform-google-onboarding/commit/c03e6efa15edc998fb7a489cc0c90232d78084e1))

## [2.4.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.3.0...v2.4.0) (2025-06-17)

### Features

* **AG-2923:** reduce storageAdmin role to only required permissions ([#9](https://github.com/upwindsecurity/terraform-google-onboarding/issues/9)) ([e16bc75](https://github.com/upwindsecurity/terraform-google-onboarding/commit/e16bc7538af8881ddee8b4d124c11fba06a9b02d))


## [2.3.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.2.0...v2.3.0) (2025-06-17)

### Features

* **AG2922:** remove token creator bindings, allow cloudscanner to impersonate scaler ([#8](https://github.com/upwindsecurity/terraform-google-onboarding/issues/8)) ([9ac7555](https://github.com/upwindsecurity/terraform-google-onboarding/commit/9ac7555b90d3f19c7c9f5e85ce6422396db9d1ef))

## [2.2.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.1.0...v2.2.0) (2025-06-17)

### Features

* **AG-2921:** add variable to control WIF project ([#6](https://github.com/upwindsecurity/terraform-google-onboarding/issues/6)) ([d1e65c0](https://github.com/upwindsecurity/terraform-google-onboarding/commit/d1e65c0d3430acde20c42f89a7468a59a70a989e))
## [2.1.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.0.0...v2.1.0) (2025-06-16)

### Features

* update release workflow and CI/CD pipeline ([#3](https://github.com/upwindsecurity/terraform-google-onboarding/issues/3)) ([870d989](https://github.com/upwindsecurity/terraform-google-onboarding/commit/870d98904360cb9b6111b55a8d037081a288f4c8))

### Bug Fixes

* clean up whitespace and formatting in workflow and documentation files ([#4](https://github.com/upwindsecurity/terraform-google-onboarding/issues/4)) ([fcaedcd](https://github.com/upwindsecurity/terraform-google-onboarding/commit/fcaedcddda35d8a8f0a5bbf7f66ebb0cbfef02e4))

## [2.0.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v1.0.0...v2.0.0) (2025-06-16)

### ⚠ BREAKING CHANGES

* **AG-2890:** this upgrades the Upwind GCP deployments
    to use Workload Identity Federation instead of directly
    using Service Accounts by creating a private key.

    An identity pool is created and trust is configured with the
    Upwind AWS account. It will be necessary for a customer to
    provide a credential configuration for WIF after creation
    using the gcloud command specified in the documentation, and
    uploading this to Upwind.

### Features

* **AG-2890:** GCP Workload Identity Federation ([#1](https://github.com/upwindsecurity/terraform-google-onboarding/issues/1)) ([629dee6](https://github.com/upwindsecurity/terraform-google-onboarding/commit/629dee6529ebd9945e6f034202a0a938b1a4da4f))

## [2.0.1](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v2.0.0...v2.0.1) (2025-06-16)

### Bug Fixes

* **AG-2911:** update changelog and manage tags ([23ba690](https://github.com/upwindsecurity/terraform-google-onboarding/commit/23ba690e942aeaacccd73395c66a4e65dd86e16f))

## [2.0.0](https://github.com/upwindsecurity/terraform-google-onboarding/compare/v1.0.0...v2.0.0) (2025-06-12)

### ⚠ BREAKING CHANGES

* **AG-2670:** Implements Workload Identity Federation for GCP organization onboarding, replacing prior Service Account key creation method.

### Features

* **AG-2670:** Implements Workload Identity Federation for GCP organization onboarding, replacing prior Service Account key creation method.

## 1.0.0 (2025-06-09)

Initial commit of onboarding modules.
