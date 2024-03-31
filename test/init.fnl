(local {: runtime-version} (require :fennel.utils))
(local faith (require :test.faith))
(local {: find-test-modules : log} (require :test.utils))

(log (runtime-version))
(log "Faith " faith.version)
(set _G._FNLDOC_DEBUG true)
(faith.run (find-test-modules))
