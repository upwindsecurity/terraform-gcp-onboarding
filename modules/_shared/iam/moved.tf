# Google grants roles/run.serviceAgent to the Cloud Run service agent when
# run.googleapis.com is enabled on a project, so this module does not manage that
# binding. One binding serves every onboarding in an orchestrator project; managing it
# here would let any one teardown delete it for all of them.
#
# This block drops the binding from state without deleting the grant, and has to stay:
# a consumer upgrading from a version that declared the resource would otherwise
# destroy the binding on its next apply.
removed {
  from = google_project_iam_member.cloudrun_service_agent

  lifecycle {
    destroy = false
  }
}
