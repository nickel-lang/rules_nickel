{
  # Note that import path does not contain "schemas" prefix.
  # This is provided via the `imports` keyword in bazel target definition.
  argo_cd = (import "./helm.ncl") & {
      repository = "https://argoproj.github.io/argo-helm",
      chart = "argo-cd",
      version = "5.53.1",
  }
}
